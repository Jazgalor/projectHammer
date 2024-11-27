package com.example.photoscanner

import android.Manifest
import android.app.Dialog
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Bundle
import android.util.Log
import android.util.Size
import android.widget.Toast
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AppCompatActivity
import androidx.camera.core.*
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.camera.view.PreviewView
import androidx.core.content.ContextCompat
import androidx.recyclerview.widget.LinearLayoutManager
import com.bumptech.glide.Glide
import com.example.photoscanner.databinding.ActivityCameraBinding
import com.example.photoscanner.databinding.DialogPhotoPreviewBinding
import com.google.android.material.bottomsheet.BottomSheetBehavior
import java.io.File
import java.text.SimpleDateFormat
import java.util.*
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors

class CameraActivity : AppCompatActivity() {
    private lateinit var binding: ActivityCameraBinding
    private lateinit var cameraExecutor: ExecutorService
    private lateinit var bottomSheetBehavior: BottomSheetBehavior<*>
    private var imageCapture: ImageCapture? = null
    private lateinit var photoAdapter: PhotoAdapter
    private var photoCount: Int = 0
    private val REQUIRED_PHOTOS: Int = 5
    private lateinit var outputDirectory: File

    private val REQUIRED_PERMISSIONS = arrayOf(Manifest.permission.CAMERA)

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

        setupUI()
        
        if (allPermissionsGranted()) {
            startCamera()
        } else {
            requestPermissionLauncher.launch(REQUIRED_PERMISSIONS)
        }
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

        binding.doneButton.setOnClickListener {
            if (photoCount >= REQUIRED_PHOTOS) {
                // TODO: Handle completion
                Toast.makeText(this, "Gotowe!", Toast.LENGTH_SHORT).show()
            } else {
                Toast.makeText(this, "Wykonaj minimum ${REQUIRED_PHOTOS} zdjęć", Toast.LENGTH_SHORT).show()
            }
        }
    }

    private fun updatePhotoCounter() {
        binding.photoCounterText.text = "$photoCount"
        
        // Change color based on progress
        val textColor = when {
            photoCount >= REQUIRED_PHOTOS -> android.graphics.Color.parseColor("#4CAF50") // Green when complete
            photoCount >= 3 -> android.graphics.Color.parseColor("#FFC107") // Yellow when close
            else -> android.graphics.Color.WHITE // White otherwise
        }
        binding.photoCounterText.setTextColor(textColor)
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
                // Save the original JPEG without any rotation
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
                    photoCount++
                    updatePhotoCounter()
                    Toast.makeText(
                        this@CameraActivity,
                        getString(R.string.photo_taken),
                        Toast.LENGTH_SHORT
                    ).show()
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
                .setTargetResolution(Size(4032, 3024)) // Maximum resolution for most phones
                .setJpegQuality(100) // Maximum JPEG quality
                .build()

            try {
                cameraProvider.unbindAll()
                cameraProvider.bindToLifecycle(
                    this,
                    CameraSelector.DEFAULT_BACK_CAMERA,
                    preview,
                    imageCapture
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
    }

    companion object {
        private const val TAG = "CameraActivity"
        private const val FILENAME_FORMAT = "yyyy-MM-dd-HH-mm-ss-SSS"
    }
}
