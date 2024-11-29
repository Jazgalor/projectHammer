package com.example.photoscanner

import android.net.Uri
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import androidx.recyclerview.widget.RecyclerView
import com.bumptech.glide.Glide
import com.example.photoscanner.databinding.ItemPhotoBinding

class PhotoAdapter(private val onLongClick: (Int) -> Unit) : RecyclerView.Adapter<PhotoAdapter.PhotoViewHolder>() {
    // Lista URI zdjęć
    private val photos = mutableListOf<Uri>()
    
    // Callback dla kliknięcia zdjęcia
    var onPhotoClicked: ((Uri) -> Unit)? = null

    fun addPhoto(uri: Uri) {
        // Dodaj nowe zdjęcie do galerii
        photos.add(uri)
        notifyItemInserted(photos.size - 1)
    }

    fun removePhoto(position: Int) {
        // Usuń zdjęcie z galerii
        if (position in photos.indices) {
            photos.removeAt(position)
            notifyItemRemoved(position)
        }
    }

    fun getPhotos(): List<Uri> = photos.toList()

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): PhotoViewHolder {
        val binding = ItemPhotoBinding.inflate(
            LayoutInflater.from(parent.context),
            parent,
            false
        )
        return PhotoViewHolder(binding.root)
    }

    override fun onBindViewHolder(holder: PhotoViewHolder, position: Int) {
        holder.bind(photos[position])
    }

    override fun getItemCount() = photos.size

    inner class PhotoViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        private val imageView: ImageView = itemView.findViewById(R.id.photoImage)

        init {
            // Konfiguracja długiego kliknięcia do usuwania
            itemView.setOnLongClickListener {
                onLongClick(adapterPosition)
                true
            }
            
            // Konfiguracja kliknięcia do podglądu
            itemView.setOnClickListener {
                onPhotoClicked?.invoke(photos[adapterPosition])
            }
        }

        fun bind(uri: Uri) {
            // Załaduj zdjęcie do ImageView używając Glide
            Glide.with(itemView.context)
                .load(uri)
                .centerCrop()
                .into(imageView)
        }
    }
}
