package com.digitalnative.dn_audio

import android.Manifest
import android.content.ContentUris
import android.content.pm.PackageManager
import android.database.Cursor
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.Typeface
import android.media.MediaMetadataRetriever
import android.net.Uri
import android.os.Build
import android.provider.MediaStore
import java.io.File
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : AudioServiceActivity() {
    private val channelName = "dn_audio/audio_library"
    private val audioEffectsChannelName = "dn_audio/audio_effects"
    private val permissionRequestCode = 7412
    private var permissionResult: MethodChannel.Result? = null
    private val audioEffectsManager = AudioEffectsManager()

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, audioEffectsChannelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "attachSession" -> {
                        val sessionId = call.argument<Int>("sessionId")
                        if (sessionId == null) {
                            result.error(
                                "invalid_arguments",
                                "A valid sessionId is required.",
                                null
                            )
                        } else {
                            result.success(audioEffectsManager.attachSession(sessionId))
                        }
                    }
                    "getCapabilities" -> result.success(audioEffectsManager.getCapabilities())
                    "setEqualizerEnabled" -> {
                        val enabled = call.argument<Boolean>("enabled")
                        if (enabled == null) {
                            result.error("invalid_arguments", "A valid enabled value is required.", null)
                        } else {
                            result.success(audioEffectsManager.setEqualizerEnabled(enabled))
                        }
                    }
                    "setBandLevel" -> {
                        val bandIndex = call.argument<Int>("bandIndex")
                        val levelMillibels = call.argument<Int>("levelMillibels")
                        if (bandIndex == null || levelMillibels == null) {
                            result.error(
                                "invalid_arguments",
                                "bandIndex and levelMillibels are required.",
                                null
                            )
                        } else {
                            result.success(
                                audioEffectsManager.setBandLevel(bandIndex, levelMillibels)
                            )
                        }
                    }
                    "setBassBoost" -> {
                        val enabled = call.argument<Boolean>("enabled")
                        val strength = call.argument<Int>("strength")
                        if (enabled == null || strength == null) {
                            result.error(
                                "invalid_arguments",
                                "enabled and strength are required.",
                                null
                            )
                        } else {
                            result.success(audioEffectsManager.setBassBoost(enabled, strength))
                        }
                    }
                    "setVirtualizer" -> {
                        val enabled = call.argument<Boolean>("enabled")
                        val strength = call.argument<Int>("strength")
                        if (enabled == null || strength == null) {
                            result.error(
                                "invalid_arguments",
                                "enabled and strength are required.",
                                null
                            )
                        } else {
                            result.success(audioEffectsManager.setVirtualizer(enabled, strength))
                        }
                    }
                    "release" -> {
                        audioEffectsManager.release()
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "hasPermission" -> result.success(hasAudioPermission())
                    "requestPermission" -> requestAudioPermission(result)
                    "getSongs" -> {
                        if (!hasAudioPermission()) {
                            result.error("permission_denied", "Audio permission has not been granted.", null)
                        } else {
                            try {
                                val extensions = call.argument<List<String>>("extensions")
                            result.success(queryAudioFiles(extensions))
                            } catch (error: Exception) {
                                result.error("scan_failed", error.message, null)
                            }
                        }
                    }
                    "getArtworkCacheInfo" -> {
                        Thread {
                            val cacheInfo = try {
                                getArtworkCacheInfo()
                            } catch (_: Exception) {
                                mapOf("fileCount" to 0, "totalBytes" to 0L)
                            }
                            runOnUiThread { result.success(cacheInfo) }
                        }.start()
                    }
                    "resolveArtwork" -> {
                        val contentUri = call.argument<String>("contentUri")
                        val songId = call.argument<String>("songId")
                        if (contentUri.isNullOrBlank() || songId.isNullOrBlank()) {
                            result.error("invalid_arguments", "contentUri and songId are required.", null)
                        } else {
                            Thread {
                                val artworkUri = try {
                                    resolveArtwork(contentUri, songId)
                                } catch (_: Exception) {
                                    null
                                }
                                runOnUiThread { result.success(artworkUri) }
                            }.start()
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun requiredAudioPermission(): String =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            Manifest.permission.READ_MEDIA_AUDIO
        } else {
            Manifest.permission.READ_EXTERNAL_STORAGE
        }

    private fun hasAudioPermission(): Boolean =
        ContextCompat.checkSelfPermission(this, requiredAudioPermission()) ==
            PackageManager.PERMISSION_GRANTED

    private fun requestAudioPermission(result: MethodChannel.Result) {
        if (hasAudioPermission()) {
            result.success(true)
            return
        }
        if (permissionResult != null) {
            result.error("request_in_progress", "An audio permission request is already active.", null)
            return
        }
        permissionResult = result
        ActivityCompat.requestPermissions(
            this,
            arrayOf(requiredAudioPermission()),
            permissionRequestCode
        )
    }

    @Deprecated("Deprecated in Android API; retained for FlutterActivity permission callback.")
    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == permissionRequestCode) {
            val granted = grantResults.isNotEmpty() &&
                grantResults[0] == PackageManager.PERMISSION_GRANTED
            permissionResult?.success(granted)
            permissionResult = null
        }
    }

    private fun resolveArtwork(contentUriValue: String, songId: String): String? {
        val audioUri = Uri.parse(contentUriValue)
        var artworkBytes: ByteArray? = null

        // Prefer the album artwork already indexed by Android MediaStore.
        val projection = arrayOf(MediaStore.Audio.Media.ALBUM_ID)
        contentResolver.query(audioUri, projection, null, null, null)?.use { cursor ->
            if (cursor.moveToFirst()) {
                val albumId = cursor.getLong(
                    cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.ALBUM_ID)
                )
                if (albumId > 0) {
                    val albumArtUri = ContentUris.withAppendedId(
                        Uri.parse("content://media/external/audio/albumart"),
                        albumId
                    )
                    artworkBytes = try {
                        contentResolver.openInputStream(albumArtUri)?.use { it.readBytes() }
                    } catch (_: Exception) {
                        null
                    }
                }
            }
        }

        // ByteArray has no isNullOrEmpty extension; check null and emptiness safely.
        // If MediaStore has no readable cover, try artwork embedded in the audio file.
        if (artworkBytes?.isEmpty() != false) {
            val retriever = MediaMetadataRetriever()
            try {
                retriever.setDataSource(this, audioUri)
                artworkBytes = retriever.embeddedPicture
            } catch (_: Exception) {
                // Artwork is optional; continue without a cover.
            } finally {
                try {
                    retriever.release()
                } catch (_: Exception) {
                    // Ignore release errors; playback must remain unaffected.
                }
            }
        }

        val artworkDirectory = File(cacheDir, "dn_audio_artwork")
        if (!artworkDirectory.exists() && !artworkDirectory.mkdirs()) return null

        val safeSongId = songId.replace(Regex("[^A-Za-z0-9_-]"), "_")
        val artworkFile = File(artworkDirectory, "$safeSongId.png")
        val resolvedArtworkBytes = artworkBytes
        if (resolvedArtworkBytes != null && resolvedArtworkBytes.isNotEmpty()) {
            artworkFile.writeBytes(resolvedArtworkBytes)
        } else {
            createArtworkPlaceholder(artworkFile)
        }
        return Uri.fromFile(artworkFile).toString()
    }

    private fun getArtworkCacheInfo(): Map<String, Any> {
        val directory = File(cacheDir, "dn_audio_artwork")
        if (!directory.exists() || !directory.isDirectory) {
            return mapOf("fileCount" to 0, "totalBytes" to 0L)
        }

        var fileCount = 0
        var totalBytes = 0L
        directory.walkTopDown().forEach { file ->
            if (file.isFile) {
                fileCount++
                totalBytes += file.length()
            }
        }
        return mapOf("fileCount" to fileCount, "totalBytes" to totalBytes)
    }

    private fun createArtworkPlaceholder(file: File) {
        val size = 512
        val bitmap = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)
        canvas.drawColor(Color.rgb(21, 21, 29))

        val circlePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.rgb(155, 110, 243)
        }
        canvas.drawCircle(size / 2f, size / 2f - 18f, 142f, circlePaint)

        val notePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.WHITE
            textAlign = Paint.Align.CENTER
            textSize = 220f
            typeface = Typeface.create("sans-serif", Typeface.BOLD)
        }
        canvas.drawText("♪", size / 2f, size / 2f + 58f, notePaint)

        val brandPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.rgb(183, 148, 246)
            textAlign = Paint.Align.CENTER
            textSize = 34f
            typeface = Typeface.create("sans-serif-medium", Typeface.NORMAL)
        }
        canvas.drawText("DN AUDIO", size / 2f, 466f, brandPaint)

        file.outputStream().use { output ->
            bitmap.compress(Bitmap.CompressFormat.PNG, 100, output)
        }
        bitmap.recycle()
    }

    private fun readMetadata(cursor: Cursor, columnIndex: Int, fallback: String): String {
        val value = cursor.getString(columnIndex)?.trim()
        return value
            ?.takeIf { it.isNotEmpty() && !it.equals(MediaStore.UNKNOWN_STRING, ignoreCase = true) }
            ?: fallback
    }

    private fun queryAudioFiles(requestedExtensions: List<String>?): List<Map<String, Any?>> {
        val supportedExtensions = setOf("mp3", "flac", "wav", "m4a", "aac", "ogg", "opus")
        val extensions = (requestedExtensions ?: supportedExtensions.toList())
            .map { it.trim().lowercase().removePrefix(".") }
            .filter { it in supportedExtensions }
            .distinct()

        // An intentionally empty selection means the user disabled every format.
        if (extensions.isEmpty()) return emptyList()

        val collection = MediaStore.Audio.Media.EXTERNAL_CONTENT_URI
        val projection = arrayOf(
            MediaStore.Audio.Media._ID,
            MediaStore.Audio.Media.TITLE,
            MediaStore.Audio.Media.ARTIST,
            MediaStore.Audio.Media.ALBUM,
            MediaStore.Audio.Media.DURATION,
            MediaStore.Audio.Media.SIZE,
            MediaStore.Audio.Media.ALBUM_ID,
            MediaStore.Audio.Media.ARTIST_ID,
            MediaStore.Audio.Media.DATE_ADDED
        )
        val songs = mutableListOf<Map<String, Any?>>()
        val extensionSelection = extensions.joinToString(" OR ") {
            "LOWER(${MediaStore.Audio.Media.DISPLAY_NAME}) LIKE ?"
        }
        val selection = "(${MediaStore.Audio.Media.DURATION} > 0) AND ($extensionSelection)"
        val selectionArgs = extensions.map { "%.$it" }.toTypedArray()
        val cursor: Cursor? = contentResolver.query(
            collection,
            projection,
            selection,
            selectionArgs,
            "${MediaStore.Audio.Media.TITLE} COLLATE NOCASE ASC"
        )

        cursor?.use {
            val idColumn = it.getColumnIndexOrThrow(MediaStore.Audio.Media._ID)
            val titleColumn = it.getColumnIndexOrThrow(MediaStore.Audio.Media.TITLE)
            val artistColumn = it.getColumnIndexOrThrow(MediaStore.Audio.Media.ARTIST)
            val albumColumn = it.getColumnIndexOrThrow(MediaStore.Audio.Media.ALBUM)
            val durationColumn = it.getColumnIndexOrThrow(MediaStore.Audio.Media.DURATION)
            val sizeColumn = it.getColumnIndexOrThrow(MediaStore.Audio.Media.SIZE)
            val albumIdColumn = it.getColumnIndexOrThrow(MediaStore.Audio.Media.ALBUM_ID)
            val artistIdColumn = it.getColumnIndexOrThrow(MediaStore.Audio.Media.ARTIST_ID)
            val dateAddedColumn = it.getColumnIndexOrThrow(MediaStore.Audio.Media.DATE_ADDED)

            while (it.moveToNext()) {
                val id = it.getLong(idColumn)
                val albumId = it.getLong(albumIdColumn)
                val artistId = it.getLong(artistIdColumn)
                val contentUri = ContentUris.withAppendedId(collection, id)
                val albumArtUri = ContentUris.withAppendedId(
                    android.net.Uri.parse("content://media/external/audio/albumart"),
                    albumId
                )
                songs.add(
                    mapOf(
                        "id" to id.toString(),
                        "title" to readMetadata(it, titleColumn, "Unknown title"),
                        "artist" to readMetadata(it, artistColumn, "Unknown artist"),
                        "album" to readMetadata(it, albumColumn, "Unknown album"),
                        "duration" to it.getLong(durationColumn),
                        "size" to it.getLong(sizeColumn),
                        "uri" to contentUri.toString(),
                        "albumArtUri" to if (albumId > 0) albumArtUri.toString() else null,
                        "albumId" to albumId,
                        "artistId" to artistId,
                        "dateAdded" to it.getLong(dateAddedColumn)
                    )
                )
            }
        }
        return songs
    }
}
