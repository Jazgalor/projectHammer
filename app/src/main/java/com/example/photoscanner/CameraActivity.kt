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
import android.graphics.ImageFormat
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
    private val REQUIRED_PHOTOS: Int = 20
    private lateinit var outputDirectory: File
    private val photoUris = mutableListOf<Uri>()
    private val sectorColors = listOf(
        android.graphics.Color.parseColor("#FF0000"), // Czerwony
        android.graphics.Color.parseColor("#FFA500"), // Pomarańczowy
        android.graphics.Color.parseColor("#32CD32")  // Zielony
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

        // Inicjalizacja czujników
        sensorManager = getSystemService(Context.SENSOR_SERVICE) as SensorManager
        rotationSensor = sensorManager.getDefaultSensor(Sensor.TYPE_ROTATION_VECTOR)

        // Inicjalizacja wykonywania aparatu
        cameraExecutor = Executors.newSingleThreadExecutor()

        // Inicjalizacja katalogu wyjściowego
        outputDirectory = getOutputDirectory()

        // Inicjalizacja adaptera zdjęć
        photoAdapter = PhotoAdapter { position ->
            photoAdapter.removePhoto(position)
            photoCount--
            updatePhotoCounter()
            if (photoCount == 0) {
                bottomSheetBehavior.state = BottomSheetBehavior.STATE_HIDDEN
            }
        }

        serverDiscoveryManager = ServerDiscoveryManager(this)

        // Konfiguracja dotykowego ustawiania ostrości
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

        // Obsługa przycisków mediów (przycisk DJI Osmo)
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
                        // Wykonaj zdjęcie po naciśnięciu przycisku Osmo
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

        // Pokaż początkową instrukcję dla Meshroom
        Toast.makeText(
            this,
            "Zrób pierwsze zdjęcie. Obiekt powinien zajmować większość kadru.",
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
                // Wykonaj zdjęcie po naciśnięciu przycisku Osmo
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
        private val ANGLE_THRESHOLD = 5f // Minimalna zmiana kąta do przetworzenia

        override fun onSensorChanged(event: SensorEvent) {
            // Konwertuj wektor obrotu na kąty orientacji
            SensorManager.getRotationMatrixFromVector(rotationMatrix, event.values)
            SensorManager.getOrientation(rotationMatrix, orientationAngles)
            
            // Pobierz azymut (obrót wokół osi Y) w stopniach
            val newOrientation = Math.toDegrees(orientationAngles[0].toDouble()).toFloat()
            
            // Przetwórz tylko wtedy, gdy kąt się zmienił znacząco
            if (Math.abs(newOrientation - lastProcessedAngle) > ANGLE_THRESHOLD) {
                currentOrientation = newOrientation
                lastProcessedAngle = newOrientation
            }
        }

        override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {
            // Obsłuż zmiany dokładności, jeśli potrzebne
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
        // Konfiguracja zachowania dolnego arkusza
        bottomSheetBehavior = BottomSheetBehavior.from(binding.bottomSheet)
        bottomSheetBehavior.state = BottomSheetBehavior.STATE_HIDDEN

        binding.closeButton.setOnClickListener {
            bottomSheetBehavior.state = BottomSheetBehavior.STATE_HIDDEN
        }

        // Konfiguracja siatki zdjęć
        binding.photoGrid.layoutManager = LinearLayoutManager(this, LinearLayoutManager.HORIZONTAL, false)
        binding.photoGrid.adapter = photoAdapter
        
        // Ustaw słuchacza kliknięć zdjęć
        photoAdapter.onPhotoClicked = { uri ->
            showPhotoPreview(uri)
        }

        // Konfiguracja przycisku pomocy
        binding.helpButton.setOnClickListener {
            showHelpDialog()
        }

        // Aktualizuj licznik zdjęć
        updatePhotoCounter()

        // Pokaż wskazówki dla Meshroom
        AlertDialog.Builder(this)
            .setTitle("Wskazówki dla Meshroom")
            .setMessage(
                "Jak robić dobre zdjęcia do rekonstrukcji 3D:\n\n" +
                "1. Zrób minimum 20 zdjęć dookoła obiektu\n" +
                "2. Każde kolejne zdjęcie rób co około 15-20 stopni\n" +
                "3. Zrób dodatkowe zdjęcia z góry pod kątem 45°\n" +
                "4. Upewnij się że:\n" +
                "   • Zdjęcia nachodzą na siebie w 70-80%\n" +
                "   • Oświetlenie jest stałe (bez cieni)\n" +
                "   • Obiekt się nie porusza\n" +
                "   • Tło jest matowe (nie błyszczy)\n\n" +
                "Im więcej zdjęć, tym lepsza rekonstrukcja 3D!"
            )
            .setPositiveButton("Rozumiem") { dialog, _ ->
                dialog.dismiss()
            }
            .show()

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
                // Pokaż ostrzegawcze okno dialogowe
                AlertDialog.Builder(this)
                    .setTitle("Za mało zdjęć")
                    .setMessage("Dla dobrej rekonstrukcji 3D zalecane jest minimum 20 zdjęć. Wysłać mimo to?")
                    .setPositiveButton("Wyślij") { _, _ ->
                        proceedWithSending()
                    }
                    .setNegativeButton("Zrób więcej zdjęć", null)
                    .show()
            } else {
                proceedWithSending()
            }
        }
    }

    private fun startServerDiscovery() {
        // Pokaż okno dialogowe wyszukiwania
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

        // Uruchom obsługę czasu
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
        }, 10000) // 10 sekundowy limit czasu

        // Uruchom wyszukiwanie serwera
        serverDiscoveryManager.startDiscovery { serverIp, _ ->
            runOnUiThread {
                progressDialog.dismiss()
                
                // Pokaż okno dialogowe potwierdzenia
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
        // Wyłącz przycisk, aby zapobiec podwójnemu kliknięciu
        binding.doneButton.isEnabled = false

        // Utwórz zamiar do powrotu do MainActivity
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
        binding.photoCounter.text = "${photoAdapter.itemCount}/20"
        binding.photoCounterText.text = "${photoAdapter.itemCount}"
        
        // Aktualizuj kolor wskaźnika postępu w zależności od liczby zdjęć
        val progress = (photoAdapter.itemCount.toFloat() / REQUIRED_PHOTOS.toFloat()) * 100
        updateProgressIndicator(progress)

        // Aktualizuj kolor górnego licznika w zależności od liczby zdjęć
        val textColor = when {
            photoAdapter.itemCount >= REQUIRED_PHOTOS -> android.graphics.Color.parseColor("#32CD32") // Zielony
            photoAdapter.itemCount >= 15 -> android.graphics.Color.parseColor("#FFA500") // Pomarańczowy
            else -> android.graphics.Color.parseColor("#FF0000") // Czerwony
        }
        binding.photoCounterText.setTextColor(textColor)
    }

    private fun takePhoto() {
        val imageCapture = imageCapture ?: return

        // Utwórz plik wyjściowy
        val photoFile = File(
            outputDirectory,
            "IMG_${System.currentTimeMillis()}.jpg"
        )

        val metadata = ImageCapture.Metadata().apply {
            // Add location if available
            isReversedHorizontal = false
            isReversedVertical = false
        }

        val outputOptions = ImageCapture.OutputFileOptions.Builder(photoFile)
            .setMetadata(metadata)
            .build()

        imageCapture.takePicture(
            outputOptions,
            ContextCompat.getMainExecutor(this),
            object : ImageCapture.OnImageSavedCallback {
                override fun onImageSaved(output: ImageCapture.OutputFileResults) {
                    val savedUri = Uri.fromFile(photoFile)
                    photoUris.add(savedUri)
                    photoCount++
                    
                    // Aktualizuj interfejs użytkownika
                    runOnUiThread {
                        // Aktualizuj galerię zdjęć
                        photoAdapter.addPhoto(savedUri)

                        updatePhotoCounter()
                        val progress = (photoCount.toFloat() / REQUIRED_PHOTOS) * 100
                        updateProgressIndicator(progress)

                        // Pokaż komunikat przewodnika
                        val message = when {
                            photoCount == 1 -> "Świetnie! Teraz przejdź w prawo lub lewo o około 15-20 stopni"
                            photoCount < REQUIRED_PHOTOS -> when {
                                photoCount % 4 == 0 -> "Dobrze! Możesz teraz zrobić kilka zdjęć z góry pod kątem 45°"
                                else -> "Kontynuuj robienie zdjęć co 15-20 stopni"
                            }
                            photoCount == REQUIRED_PHOTOS -> "Świetnie! Masz minimalną liczbę zdjęć. Możesz zrobić więcej dla lepszej jakości"
                            else -> "Więcej zdjęć = lepsza jakość modelu 3D!"
                        }
                        if (message.isNotEmpty()) {
                            Toast.makeText(this@CameraActivity, message, Toast.LENGTH_SHORT).show()
                        }
                    }
                }

                override fun onError(exc: ImageCaptureException) {
                    Log.e(TAG, "Błąd wykonania zdjęcia: ${exc.message}", exc)
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
                .setTargetResolution(Size(4000, 3000))  // 12 MP resolution
                .setTargetRotation(binding.viewFinder.display.rotation)
                .setFlashMode(ImageCapture.FLASH_MODE_AUTO)
                .setJpegQuality(100)  // Maximum quality for Meshroom processing
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

                // Włącz autofocus
                camera.cameraControl.enableTorch(false)
                camera.cameraInfo.zoomState.observe(this) { _ ->
                    // Opcjonalnie: Dodaj kontrolę zoomu, jeśli potrzebna w przyszłości
                }

                // Ustaw początkowy tryb autofocusu
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
                Log.e(TAG, "Błąd wiązania przypadku użycia", exc)
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

    private fun updateProgressIndicator(progress: Float) {
        binding.coverageProgress.progress = progress.toInt()

        // Kolor oparty tylko na całkowitej liczbie zdjęć
        val color = when {
            photoAdapter.itemCount >= REQUIRED_PHOTOS -> sectorColors[2] // Zielony przy 20+ zdjęciach
            photoAdapter.itemCount >= 15 -> sectorColors[1] // Pomarańczowy przy zbliżaniu się
            else -> sectorColors[0] // Czerwony na początku
        }

        binding.coverageProgress.setIndicatorColor(color)
        binding.rotateIcon.setColorFilter(color)
    }

    private fun showHelpDialog() {
        AlertDialog.Builder(this)
            .setTitle("Jak korzystać z aplikacji")
            .setMessage(
                "Instrukcja skanowania 3D:\n\n" +
                "1. Przygotowanie:\n" +
                "   • Umieść obiekt na matowym tle\n" +
                "   • Zapewnij dobre, stałe oświetlenie\n" +
                "   • Unikaj błyszczących powierzchni\n\n" +
                "2. Wykonywanie zdjęć:\n" +
                "   • Zrób minimum 20 zdjęć dookoła obiektu\n" +
                "   • Wykonuj zdjęcia co 15-20 stopni\n" +
                "   • Zrób dodatkowe zdjęcia z góry pod kątem 45°\n" +
                "   • Upewnij się, że zdjęcia nachodzą na siebie w 70-80%\n\n" +
                "3. Wskazówki:\n" +
                "   • Obiekt powinien zajmować większość kadru\n" +
                "   • Utrzymuj stałą odległość od obiektu\n" +
                "   • Możesz usunąć nieudane zdjęcie przytrzymując je\n" +
                "   • Im więcej zdjęć, tym lepsza jakość modelu 3D\n\n" +
                "4. Kolory postępu:\n" +
                "   • Czerwony: za mało zdjęć (0-14)\n" +
                "   • Pomarańczowy: prawie gotowe (15-19)\n" +
                "   • Zielony: minimalna liczba zdjęć (20+)\n\n" +
                "5. Wysyłanie:\n" +
                "   • Naciśnij przycisk 'Gotowe' gdy skończysz\n" +
                "   • Aplikacja automatycznie znajdzie serwer\n" +
                "   • Zdjęcia zostaną wysłane do rekonstrukcji 3D"
            )
            .setPositiveButton("Rozumiem") { dialog, _ ->
                dialog.dismiss()
            }
            .show()
    }

    companion object {
        private const val TAG = "CameraActivity"
        private const val FILENAME_FORMAT = "yyyy-MM-dd-HH-mm-ss-SSS"
        private const val REQUIRED_PHOTOS = 20 // Minimalna liczba zdjęć dla Meshroom
        private val REQUIRED_PERMISSIONS = arrayOf(Manifest.permission.CAMERA)
    }
}
