package com.example.photoscanner

import android.Manifest
import android.app.Dialog
import android.content.Context
import android.content.DialogInterface
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
import android.view.LayoutInflater
import android.widget.Toast
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AlertDialog
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

class CameraActivity : AppCompatActivity() {
    private lateinit var binding: ActivityCameraBinding
    private lateinit var cameraExecutor: ExecutorService
    private lateinit var serverDiscoveryManager: ServerDiscoveryManager
    private lateinit var bottomSheetBehavior: BottomSheetBehavior<*>
    private lateinit var sensorManager: SensorManager
    private var rotationSensor: Sensor? = null
    private var currentOrientation: Float = 0f
    private var imageCapture: ImageCapture? = null
    private lateinit var photoAdapter: PhotoAdapter
    private var photoCount: Int = 0
    private val REQUIRED_PHOTOS: Int = 5
    private lateinit var outputDirectory: File
    private val photoUris = mutableListOf<Uri>()
    private val coveredAngles = mutableSetOf<Int>()

    private val REQUIRED_PERMISSIONS = arrayOf(Manifest.permission.CAMERA)
    private val SECTOR_SIZE = 72 // 360 degrees / 5 photos = 72 degrees per sector

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

        setupUI()
        
        if (allPermissionsGranted()) {
            startCamera()
        } else {
            requestPermissionLauncher.launch(REQUIRED_PERMISSIONS)
        }
    }

    private val orientationListener = object : SensorEventListener {
        private val rotationMatrix = FloatArray(9)
        private val orientationAngles = FloatArray(3)

        override fun onSensorChanged(event: SensorEvent) {
            if (event.sensor.type == Sensor.TYPE_ROTATION_VECTOR) {
                // Convert rotation vector to azimuth (yaw) angle
                SensorManager.getRotationMatrixFromVector(rotationMatrix, event.values)
                SensorManager.getOrientation(rotationMatrix, orientationAngles)
                
                // Convert radians to degrees and normalize to 0-360
                currentOrientation = Math.toDegrees(orientationAngles[0].toDouble()).toFloat()
                currentOrientation = (currentOrientation + 360) % 360
            }
        }

        override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {}
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
            if (photoUris.size < 5) {
                Toast.makeText(this, "Wykonaj przynajmniej 5 zdjęć", Toast.LENGTH_SHORT).show()
                return@setOnClickListener
            }
            
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
                        .setPositiveButton("Wyślij") { _: DialogInterface, _: Int ->
                            sendPhotosToServer(serverIp)
                        }
                        .setNegativeButton("Anuluj", null)
                        .show()
                }
            }
        }
    }

    private fun showManualIpDialog() {
        val dialogView = DialogServerIpBinding.inflate(layoutInflater)
        AlertDialog.Builder(this)
            .setTitle("Podaj adres IP serwera")
            .setView(dialogView.root)
            .setPositiveButton("Wyślij") { _: DialogInterface, _: Int ->
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
        binding.photoCounter.text = "$photoCount/5 (minimum 5)"
        
        // Change color based on progress
        val textColor = when {
            photoCount >= REQUIRED_PHOTOS -> android.graphics.Color.parseColor("#4CAF50") // Green when complete
            photoCount >= 3 -> android.graphics.Color.parseColor("#FFC107") // Yellow when close
            else -> android.graphics.Color.WHITE // White otherwise
        }
        binding.photoCounterText.setTextColor(textColor)
    }

    private fun updateCoverageProgress(angle: Float) {
        // Convert to 0-360 range and get the sector (72 degrees each, 5 sectors total)
        val sector = ((angle + 360) % 360 / SECTOR_SIZE).toInt()
        coveredAngles.add(sector)
        
        // Update progress based on covered angles
        val progress = (coveredAngles.size * SECTOR_SIZE).coerceAtMost(360)
        binding.coverageProgress.progress = progress
        
        // Update rotate icon color based on coverage
        binding.rotateIcon.setColorFilter(
            when {
                progress >= 360 -> android.graphics.Color.parseColor("#4CAF50") // Green when complete
                progress >= 216 -> android.graphics.Color.parseColor("#FFC107") // Yellow when 3+ photos (216° = 3 * 72°)
                else -> android.graphics.Color.WHITE
            }
        )

        // Show feedback about coverage
        val message = when {
            progress >= 360 -> "Pełne pokrycie zdjęciami!"
            else -> "Kontynuj obchodzenie obiektu"
        }
        Toast.makeText(this, message, Toast.LENGTH_SHORT).show()
    }

    private fun takePhoto() {
        val imageCapture = imageCapture ?: return

        val photoFile = File(
            outputDirectory,
            SimpleDateFormat(FILENAME_FORMAT, Locale.US)
                .format(System.currentTimeMillis()) + ".jpg"
        )

        val outputOptions = ImageCapture.OutputFileOptions.Builder(photoFile)
            .setMetadata(ImageCapture.Metadata().apply {
                isReversedHorizontal = false
                isReversedVertical = false
            })
            .build()

        imageCapture.takePicture(
            outputOptions,
            ContextCompat.getMainExecutor(this),
            object : ImageCapture.OnImageSavedCallback {
                override fun onImageSaved(output: ImageCapture.OutputFileResults) {
                    val uri = Uri.fromFile(photoFile)
                    photoAdapter.addPhoto(uri)
                    photoUris.add(uri)
                    photoCount++
                    updatePhotoCounter()

                    // Update coverage progress with current orientation
                    updateCoverageProgress(currentOrientation)
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
                .build()

            val cameraSelector = CameraSelector.DEFAULT_BACK_CAMERA

            try {
                cameraProvider.unbindAll()
                cameraProvider.bindToLifecycle(
                    this, cameraSelector, preview, imageCapture
                )
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

    override fun onDestroy() {
        super.onDestroy()
        cameraExecutor.shutdown()
        serverDiscoveryManager.stopDiscovery()
    }

    companion object {
        private const val TAG = "CameraActivity"
        private const val FILENAME_FORMAT = "yyyy-MM-dd-HH-mm-ss-SSS"
    }
}
