package com.example.photoscanner

import android.Manifest
import android.app.Activity
import android.app.AlertDialog
import android.app.Dialog
import android.content.BroadcastReceiver
import android.content.Context
import android.content.DialogInterface
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.net.Uri
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.util.Size
import android.view.KeyEvent
import android.view.LayoutInflater
import android.view.MotionEvent
import android.view.View
import android.widget.Toast
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AppCompatActivity
import androidx.camera.core.*
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.core.content.ContextCompat
import androidx.lifecycle.lifecycleScope
import androidx.recyclerview.widget.LinearLayoutManager
import com.bumptech.glide.Glide
import com.example.photoscanner.databinding.ActivityCameraBinding
import com.example.photoscanner.databinding.DialogPhotoPreviewBinding
import com.example.photoscanner.databinding.DialogServerIpBinding
import com.example.photoscanner.network.PhotoUploadService
import com.example.photoscanner.network.ServerDiscoveryManager
import com.google.android.material.bottomsheet.BottomSheetBehavior
import kotlinx.coroutines.launch
import java.io.File
import java.text.SimpleDateFormat
import java.util.*
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors
import java.util.concurrent.TimeUnit

class CameraActivity : AppCompatActivity() {
    private lateinit var binding: ActivityCameraBinding
    private lateinit var cameraExecutor: ExecutorService
    private lateinit var serverDiscoveryManager: ServerDiscoveryManager
    private lateinit var bottomSheetBehavior: BottomSheetBehavior<*>
    private lateinit var sensorManager: SensorManager
    private var rotationSensor: Sensor? = null
    private var currentOrientation: Float = 0f
    private lateinit var camera: Camera
    private var imageCapture: ImageCapture? = null
    private lateinit var photoAdapter: PhotoAdapter
    private var photoCount: Int = 0
    private val REQUIRED_PHOTOS: Int = 4
    private lateinit var outputDirectory: File
    private val photoUris = mutableListOf<Uri>()
    private val sectorColors = listOf(
        android.graphics.Color.parseColor("#FF0000"), // Red
        android.graphics.Color.parseColor("#FFA500"), // Orange
        android.graphics.Color.parseColor("#32CD32")  // Green
    )

    private val REQUIRED_PERMISSIONS = arrayOf(Manifest.permission.CAMERA)
    private val ANGLE_TOLERANCE = 35 // Even more tolerance for the larger sectors
    private var lastToastTime = 0L
    private val TOAST_DELAY = 1000L

    private val requestPermissionLauncher = registerForActivityResult(
        ActivityResultContracts.RequestMultiplePermissions()
    ) { permissions ->
        if (permissions[Manifest.permission.CAMERA] == true) {
            startCamera()
        } else {
            Toast.makeText(this, "Wymagane uprawnienie aparatu", Toast.LENGTH_SHORT).show()
            finish()
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityCameraBinding.inflate(layoutInflater)
        setContentView(binding.root)

        // Initialize sensors
        sensorManager = getSystemService(Context.SENSOR_SERVICE) as SensorManager
        rotationSensor = sensorManager.getDefaultSensor(Sensor.TYPE_ROTATION_VECTOR)

        // Initialize camera executor
        cameraExecutor = Executors.newSingleThreadExecutor()

        // Initialize output directory
        outputDirectory = getOutputDirectory()

        // Initialize photoAdapter
        photoAdapter = PhotoAdapter { position ->
            photoAdapter.removePhoto(position)
            photoCount--
            updatePhotoCounter()
            if (photoCount == 0) {
                bottomSheetBehavior.state = BottomSheetBehavior.STATE_HIDDEN
            }
        }

        serverDiscoveryManager = ServerDiscoveryManager(this)

        // Setup tap to focus
        binding.viewFinder.setOnTouchListener { _, event ->
            when (event.action) {
                MotionEvent.ACTION_DOWN -> {
                    val factory = binding.viewFinder.meteringPointFactory
                    val point = factory.createPoint(event.x, event.y)
                    val action = FocusMeteringAction.Builder(point, FocusMeteringAction.FLAG_AF)
                        .setAutoCancelDuration(3, TimeUnit.SECONDS)
                        .build()
                    
                    camera.cameraControl.startFocusAndMetering(action)
                    true
                }
                else -> false
            }
        }

        // Handle media button events (DJI Osmo button)
        volumeButtonReceiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                if (intent?.action == Intent.ACTION_MEDIA_BUTTON) {
                    val event = if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.TIRAMISU) {
                        intent.getParcelableExtra(Intent.EXTRA_KEY_EVENT, KeyEvent::class.java)
                    } else {
                        @Suppress("DEPRECATION")
                        intent.getParcelableExtra(Intent.EXTRA_KEY_EVENT)
                    }
                    if ((event?.keyCode == KeyEvent.KEYCODE_VOLUME_DOWN || 
                         event?.keyCode == KeyEvent.KEYCODE_VOLUME_UP) && 
                        event.action == KeyEvent.ACTION_DOWN) {
                        // Trigger photo capture when Osmo button is pressed
                        takePhoto()
                    }
                }
            }
        }

        val filter = IntentFilter(Intent.ACTION_MEDIA_BUTTON)
        registerReceiver(volumeButtonReceiver, filter)

        setupUI()
        
        if (allPermissionsGranted()) {
            startCamera()
        } else {
            requestPermissionLauncher.launch(REQUIRED_PERMISSIONS)
        }

        // Show initial instruction
        Toast.makeText(
            this,
            "Ustaw obiekt na środku i zrób pierwsze zdjęcie",
            Toast.LENGTH_LONG
        ).show()
    }

    override fun onDestroy() {
        super.onDestroy()
        unregisterReceiver(volumeButtonReceiver)
        cameraExecutor.shutdown()
        serverDiscoveryManager.stopDiscovery()
    }

    private lateinit var volumeButtonReceiver: BroadcastReceiver

    override fun onKeyDown(keyCode: Int, event: KeyEvent?): Boolean {
        return when (keyCode) {
            KeyEvent.KEYCODE_VOLUME_DOWN,
            KeyEvent.KEYCODE_VOLUME_UP -> {
                // Handle Osmo button press
                takePhoto()
                true
            }
            else -> super.onKeyDown(keyCode, event)
        }
    }

    private val orientationListener = object : SensorEventListener {
        private val rotationMatrix = FloatArray(9)
        private val orientationAngles = FloatArray(3)
        private var lastProcessedAngle = 0f
        private val ANGLE_THRESHOLD = 5f // Minimum angle change to process

        override fun onSensorChanged(event: SensorEvent) {
            // Convert rotation vector to orientation angles
            SensorManager.getRotationMatrixFromVector(rotationMatrix, event.values)
            SensorManager.getOrientation(rotationMatrix, orientationAngles)
            
            // Get azimuth (rotation around Y-axis) in degrees
            val newOrientation = Math.toDegrees(orientationAngles[0].toDouble()).toFloat()
            
            // Only process if angle changed significantly
            if (Math.abs(newOrientation - lastProcessedAngle) > ANGLE_THRESHOLD) {
                currentOrientation = newOrientation
                lastProcessedAngle = newOrientation
            }
        }

        override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {
            // Handle accuracy changes if needed
        }
    }

    override fun onResume() {
        super.onResume()
        rotationSensor?.let {
            sensorManager.registerListener(orientationListener, it, SensorManager.SENSOR_DELAY_NORMAL)
        }
    }

    override fun onPause() {
        super.onPause()
        sensorManager.unregisterListener(orientationListener)
    }

    private fun setupUI() {
        // Setup bottom sheet behavior
        bottomSheetBehavior = BottomSheetBehavior.from(binding.bottomSheet)
        bottomSheetBehavior.state = BottomSheetBehavior.STATE_HIDDEN

        binding.closeButton.setOnClickListener {
            bottomSheetBehavior.state = BottomSheetBehavior.STATE_HIDDEN
        }

        // Setup photo grid
        photoAdapter.onPhotoClicked = { uri ->
            showPhotoPreview(uri)
        }

        binding.photoGrid.apply {
            layoutManager = LinearLayoutManager(this@CameraActivity, LinearLayoutManager.HORIZONTAL, false)
            adapter = photoAdapter
        }

        binding.galleryButton.setOnClickListener {
            if (photoCount > 0) {
                if (bottomSheetBehavior.state == BottomSheetBehavior.STATE_HIDDEN) {
                    bottomSheetBehavior.state = BottomSheetBehavior.STATE_EXPANDED
                } else {
                    bottomSheetBehavior.state = BottomSheetBehavior.STATE_HIDDEN
                }
            }
        }

        binding.captureButton.setOnClickListener {
            takePhoto()
        }

        setupDoneButton()

    }

    private fun setupDoneButton() {
        binding.doneButton.setOnClickListener {
            if (photoCount < REQUIRED_PHOTOS) {
                // Show warning dialog
                android.app.AlertDialog.Builder(this)
                    .setTitle("Za mało zdjęć")
                    .setMessage("Zalecane minimum to 4 zdjęcia. Wysłać mimo to?")
                    .setPositiveButton("Wyślij") { _, _ ->
                        startServerDiscovery()
                    }
                    .setNegativeButton("Zrób więcej zdjęć", null)
                    .show()
            } else {
                startServerDiscovery()
            }
        }
    }

    private fun startServerDiscovery() {
        // Show searching dialog
        val progressDialog = AlertDialog.Builder(this)
            .setTitle("Szukanie serwera")
            .setMessage("Szukam serwera w sieci lokalnej...")
            .setCancelable(true)
            .setNegativeButton("Anuluj") { dialog: DialogInterface, _: Int ->
                dialog.dismiss()
                serverDiscoveryManager.stopDiscovery()
            }
            .setNeutralButton("Wpisz IP ręcznie") { dialog: DialogInterface, _: Int ->
                dialog.dismiss()
                serverDiscoveryManager.stopDiscovery()
                showManualIpDialog()
            }
            .show()

        // Start timeout handler
        Handler(Looper.getMainLooper()).postDelayed({
            if (progressDialog.isShowing) {
                progressDialog.dismiss()
                serverDiscoveryManager.stopDiscovery()
                AlertDialog.Builder(this)
                    .setTitle("Nie znaleziono serwera")
                    .setMessage("Czy chcesz wpisać adres IP ręcznie?")
                    .setPositiveButton("Tak") { _: DialogInterface, _: Int -> showManualIpDialog() }
                    .setNegativeButton("Nie", null)
                    .show()
            }
        }, 10000) // 10 second timeout

        // Start server discovery
        serverDiscoveryManager.startDiscovery { serverIp, _ ->
            runOnUiThread {
                progressDialog.dismiss()
                
                // Show confirmation dialog
                AlertDialog.Builder(this)
                    .setTitle("Znaleziono serwer")
                    .setMessage("Czy chcesz wysłać zdjęcia do serwera: $serverIp?")
                    .setPositiveButton("Wyślij") { _, _ ->
                        sendPhotosToServer(serverIp)
                    }
                    .setNegativeButton("Anuluj", null)
                    .show()
            }
        }
    }

    private fun proceedWithSending() {
        // Disable the button to prevent double-clicks
        binding.doneButton.isEnabled = false

        // Create intent to return to MainActivity
        val resultIntent = Intent().apply {
            putExtra("photoUris", ArrayList(photoUris))
        }
        setResult(Activity.RESULT_OK, resultIntent)
        finish()
    }

    private fun showManualIpDialog() {
        val dialogView = DialogServerIpBinding.inflate(layoutInflater)
        AlertDialog.Builder(this)
            .setTitle("Podaj adres IP serwera")
            .setView(dialogView.root)
            .setPositiveButton("Wyślij") { _, _ ->
                val serverIp = dialogView.ipInput.text.toString()
                if (serverIp.isNotEmpty()) {
                    sendPhotosToServer(serverIp)
                }
            }
            .setNegativeButton("Anuluj", null)
            .show()
    }

    private fun sendPhotosToServer(serverIp: String) {
        lifecycleScope.launch {
            binding.doneButton.isEnabled = false
            val success = PhotoUploadService.uploadPhotos(this@CameraActivity, serverIp, photoUris)
            binding.doneButton.isEnabled = true
            
            Toast.makeText(
                this@CameraActivity,
                if (success) "Zdjęcia wysłane pomyślnie" else "Błąd wysyłania zdjęć",
                Toast.LENGTH_SHORT
            ).show()
        }
    }

    private fun updatePhotoCounter() {
        binding.photoCounterText.text = "$photoCount"
        binding.photoCounter.text = "$photoCount/4"
        
        // Change color based on total photos
        val textColor = when {
            photoCount >= REQUIRED_PHOTOS -> android.graphics.Color.parseColor("#32CD32") // Green
            photoCount >= 3 -> android.graphics.Color.parseColor("#FFA500") // Orange
            else -> android.graphics.Color.parseColor("#FF0000") // Red
        }
        binding.photoCounterText.setTextColor(textColor)
    }

    private fun updateProgressIndicator(progress: Float) {
        binding.coverageProgress.progress = progress.toInt()

        // Color based only on total photos
        val color = when {
            photoCount >= REQUIRED_PHOTOS -> sectorColors[2] // Green when 4+ photos
            photoCount >= 3 -> sectorColors[1] // Orange when getting close
            else -> sectorColors[0] // Red at start
        }

        binding.coverageProgress.setIndicatorColor(color)
        binding.rotateIcon.setColorFilter(color)
    }

    private fun takePhoto() {
        val imageCapture = imageCapture ?: return

        // Create output file
        val photoFile = File(
            outputDirectory,
            "IMG_${System.currentTimeMillis()}.jpg"
        )

        val outputOptions = ImageCapture.OutputFileOptions.Builder(photoFile).build()

        imageCapture.takePicture(
            outputOptions,
            ContextCompat.getMainExecutor(this),
            object : ImageCapture.OnImageSavedCallback {
                override fun onImageSaved(output: ImageCapture.OutputFileResults) {
                    val savedUri = Uri.fromFile(photoFile)
                    photoUris.add(savedUri)
                    photoCount++
                    
                    // Update UI
                    runOnUiThread {
                        // Update photo gallery
                        photoAdapter.addPhoto(savedUri)
                        if (bottomSheetBehavior.state == BottomSheetBehavior.STATE_HIDDEN && photoCount == 1) {
                            bottomSheetBehavior.state = BottomSheetBehavior.STATE_EXPANDED
                        }

                        updatePhotoCounter()
                        val progress = (photoCount.toFloat() / REQUIRED_PHOTOS) * 100
                        updateProgressIndicator(progress)

                        // Show guidance message
                        val message = when (photoCount) {
                            1 -> "Przejdź w prawo o około 90°"
                            2 -> "Dobrze! Jeszcze raz w prawo o 90°"
                            3 -> "Świetnie! Ostatnia pozycja"
                            4 -> "Gotowe!"
                            else -> "" // No message after 4 photos
                        }
                        if (message.isNotEmpty()) {
                            Toast.makeText(this@CameraActivity, message, Toast.LENGTH_SHORT).show()
                        }
                    }
                }

                override fun onError(exc: ImageCaptureException) {
                    Log.e(TAG, "Photo capture failed: ${exc.message}", exc)
                }
            }
        )
    }

    private fun startCamera() {
        val cameraProviderFuture = ProcessCameraProvider.getInstance(this)

        cameraProviderFuture.addListener({
            val cameraProvider: ProcessCameraProvider = cameraProviderFuture.get()

            val preview = Preview.Builder()
                .build()
                .also {
                    it.setSurfaceProvider(binding.viewFinder.surfaceProvider)
                }

            imageCapture = ImageCapture.Builder()
                .setCaptureMode(ImageCapture.CAPTURE_MODE_MAXIMIZE_QUALITY)
                .setTargetResolution(Size(1920, 1440)) // 4:3 aspect ratio with good resolution
                .setFlashMode(ImageCapture.FLASH_MODE_AUTO)
                .setJpegQuality(95)
                .build()

            val cameraSelector = CameraSelector.Builder()
                .requireLensFacing(CameraSelector.LENS_FACING_BACK)
                .build()

            try {
                cameraProvider.unbindAll()
                camera = cameraProvider.bindToLifecycle(
                    this,
                    cameraSelector,
                    preview,
                    imageCapture
                )

                // Enable auto-focus
                camera.cameraControl.enableTorch(false)
                camera.cameraInfo.zoomState.observe(this) { _ ->
                    // Optional: Add zoom controls if needed in the future
                }

                // Set up initial focus mode
                val factory = binding.viewFinder.meteringPointFactory
                val centerPoint = factory.createPoint(
                    binding.viewFinder.width / 2f,
                    binding.viewFinder.height / 2f
                )
                val action = FocusMeteringAction.Builder(centerPoint, FocusMeteringAction.FLAG_AF)
                    .setAutoCancelDuration(3, TimeUnit.SECONDS)
                    .build()
                camera.cameraControl.startFocusAndMetering(action)

            } catch (exc: Exception) {
                Log.e(TAG, "Use case binding failed", exc)
            }
        }, ContextCompat.getMainExecutor(this))
    }

    private fun allPermissionsGranted() = REQUIRED_PERMISSIONS.all {
        ContextCompat.checkSelfPermission(baseContext, it) == PackageManager.PERMISSION_GRANTED
    }

    private fun showPhotoPreview(uri: Uri) {
        val dialog = Dialog(this, android.R.style.Theme_Black_NoTitleBar_Fullscreen)
        val dialogBinding = DialogPhotoPreviewBinding.inflate(layoutInflater)
        dialog.setContentView(dialogBinding.root)

        Glide.with(this)
            .load(uri)
            .into(dialogBinding.previewImageView)

        dialogBinding.closePreviewButton.setOnClickListener {
            dialog.dismiss()
        }

        dialog.show()
    }

    private fun getOutputDirectory(): File {
        val mediaDir = externalMediaDirs.firstOrNull()?.let {
            File(it, resources.getString(R.string.app_name)).apply { mkdirs() }
        }
        return if (mediaDir != null && mediaDir.exists()) mediaDir else filesDir
    }

    companion object {
        private const val TAG = "CameraActivity"
        private const val FILENAME_FORMAT = "yyyy-MM-dd-HH-mm-ss-SSS"
        private const val REQUIRED_PHOTOS: Int = 4
    }
}
