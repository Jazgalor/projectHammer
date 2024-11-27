package com.example.photoscanner.network

import android.net.Uri
import android.content.Context
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.io.File
import java.io.OutputStream
import java.net.Socket
import java.nio.charset.StandardCharsets

class PhotoUploadService {
    companion object {
        private const val SERVER_PORT = 5000
        private const val BUFFER_SIZE = 4096
        private const val DELIMITER = "\n"
        
        suspend fun uploadPhotos(context: Context, serverIp: String, photos: List<Uri>) = withContext(Dispatchers.IO) {
            try {
                Socket(serverIp, SERVER_PORT).use { socket ->
                    val outputStream: OutputStream = socket.getOutputStream()
                    
                    // Send number of files first
                    outputStream.write("${photos.size}$DELIMITER".toByteArray(StandardCharsets.UTF_8))
                    outputStream.flush()
                    
                    photos.forEach { photoUri ->
                        // Get the file name
                        val fileName = photoUri.lastPathSegment ?: "photo_${System.currentTimeMillis()}.jpg"
                        
                        // Get file size
                        val fileSize = context.contentResolver.openInputStream(photoUri)?.use { it.available().toLong() } ?: 0L
                        
                        // Send file info: name and size
                        outputStream.write("$fileName$DELIMITER$fileSize$DELIMITER".toByteArray(StandardCharsets.UTF_8))
                        outputStream.flush()
                        
                        // Send the file content
                        context.contentResolver.openInputStream(photoUri)?.use { inputStream ->
                            val buffer = ByteArray(BUFFER_SIZE)
                            var bytesRead: Int
                            var totalBytesRead = 0L
                            while (inputStream.read(buffer).also { bytesRead = it } != -1) {
                                outputStream.write(buffer, 0, bytesRead)
                                totalBytesRead += bytesRead
                                if (totalBytesRead >= fileSize) break
                            }
                            outputStream.flush()
                        }
                    }
                }
                true
            } catch (e: Exception) {
                e.printStackTrace()
                false
            }
        }
    }
}
