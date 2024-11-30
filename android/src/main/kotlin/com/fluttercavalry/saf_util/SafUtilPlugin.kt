package com.fluttercavalry.saf_util

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.database.Cursor
import android.graphics.Bitmap
import android.graphics.Point
import android.media.MediaMetadataRetriever
import android.media.MediaMetadataRetriever.OPTION_CLOSEST_SYNC
import android.net.Uri
import android.os.Build
import android.provider.DocumentsContract
import androidx.documentfile.provider.DocumentFile
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import java.io.File


/** SafUtilPlugin */
class SafUtilPlugin: FlutterPlugin, MethodCallHandler, ActivityAware {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel

  private lateinit var context: Context
  private var activity: Activity? = null

  private var pendingResult: Result? = null
  private var pendingArguments: PendingArguments? = null
  private val requestCodeOpenDocumentTree = 1001
  private val requestCodeOpenFiles = 1002

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "saf_util")
    channel.setMethodCallHandler(this)
    context = flutterPluginBinding.applicationContext
  }

  override fun onDetachedFromActivity() {
    activity = null
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    activity = binding.activity
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity
    binding.addActivityResultListener { requestCode, resultCode, data ->
      onActivityResult(requestCode, resultCode, data)
      true
    }
  }

  override fun onDetachedFromActivityForConfigChanges() {
    activity = null
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      "list" -> {
        CoroutineScope(Dispatchers.IO).launch {
          var cursor: Cursor? = null
          try {
            val uri = call.argument<String>("uri") as String

            val dir = documentFileFromUri(uri, true) ?: throw Exception("Failed to get DocumentFile from $uri")
            val resolver = context.contentResolver
            val mUri = dir.uri
            val childrenUri = DocumentsContract.buildChildDocumentsUriUsingTree(
              mUri,
              DocumentsContract.getDocumentId(mUri)
            )
            val results = mutableListOf<Map<String, Any?>>()

            cursor = resolver.query(
              childrenUri,
              arrayOf(
                DocumentsContract.Document.COLUMN_DOCUMENT_ID,
                DocumentsContract.Document.COLUMN_DISPLAY_NAME,
                DocumentsContract.Document.COLUMN_SIZE,
                DocumentsContract.Document.COLUMN_MIME_TYPE,
                DocumentsContract.Document.COLUMN_LAST_MODIFIED
              ),
              null,
              null,
              null
            )

            while (cursor?.moveToNext() == true) {
              val documentId = cursor.getString(0)
              val fileName = cursor.getString(1)
              val fileSize = cursor.getLong(2)
              val mimeType = cursor.getString(3)
              val lastModified = cursor.getLong(4)
              val documentUri = DocumentsContract.buildDocumentUriUsingTree(mUri, documentId)

              // Determine if the file is a directory based on the MIME type
              val isDirectory = DocumentsContract.Document.MIME_TYPE_DIR == mimeType

              // Create a dictionary (map) for each file with its details
              val fileInfo = fileObjMap(
                documentUri,
                isDirectory,
                fileName,
                fileSize.toInt(),
                lastModified,
              )
              results.add(fileInfo)
            }

            launch(Dispatchers.Main) { result.success(results) }
          } catch (err: Exception) {
            launch(Dispatchers.Main) {
              result.error("PluginError", err.message, null)
            }
          } finally {
            try {
              cursor?.close()
            } catch (_: Exception) {
            }
          }
        }
      }

      "documentFileFromUri" -> {
        CoroutineScope(Dispatchers.IO).launch {
          try {
            val uri = call.argument<String>("uri") as String
            val isDir = call.argument<Boolean>("isDir") as Boolean

            val df = documentFileFromUri(uri, isDir)
            if (df == null) {
              launch(Dispatchers.Main) {
                result.success(null)
              }
              return@launch
            }
            launch(Dispatchers.Main) {
              result.success(fileObjMapFromDocumentFile(df))
            }
          } catch (err: Exception) {
            launch(Dispatchers.Main) {
              result.error("PluginError", err.message, null)
            }
          }
        }
      }

      "exists" -> {
        CoroutineScope(Dispatchers.IO).launch {
          try {
            val uri = call.argument<String>("uri") as String
            val isDir = call.argument<Boolean>("isDir") as Boolean

            val df = documentFileFromUri(uri, isDir)
            if (df == null) {
              launch(Dispatchers.Main) {
                result.success(false)
              }
              return@launch
            }
            launch(Dispatchers.Main) {
              result.success(df.exists())
            }
          } catch (err: Exception) {
            launch(Dispatchers.Main) {
              result.error("PluginError", err.message, null)
            }
          }
        }
      }

      "delete" -> {
        CoroutineScope(Dispatchers.IO).launch {
          try {
            val uri = call.argument<String>("uri") as String
            val isDir = call.argument<Boolean>("isDir") as Boolean

            val df = documentFileFromUri(uri, isDir) ?: throw Exception("Failed to get DocumentFile from $uri")
            launch(Dispatchers.Main) {
              result.success(df.delete())
            }
          } catch (err: Exception) {
            launch(Dispatchers.Main) {
              result.error("PluginError", err.message, null)
            }
          }
        }
      }

      "mkdirp" -> {
        CoroutineScope(Dispatchers.IO).launch {
          try {
            val uri = call.argument<String?>("uri") as String
            val names =
              call.argument<ArrayList<String>>("names") as ArrayList<String>

            var curDocument = documentFileFromUri(uri, true) ?: throw Exception("Failed to get DocumentFile from $uri")
            for (curName in names) {
              val findRes = findDirectChild(curDocument.uri, curName)
              val nextDocument: DocumentFile?
              if (findRes == null) {
                val createRes = curDocument.createDirectory(curName)
                if (createRes != null && createRes.name != curName) {
                  // There are cases where the created directory has a different name due to concurrent operations.
                  // In this case, we need to find the directory with the correct name again.
                  val findRes2 = findDirectChild(curDocument.uri, curName)
                  nextDocument = if (findRes2 != null) {
                    documentFileFromUriObj(findRes2.uri, findRes2.isDir)
                  } else {
                    null
                  }
                } else {
                  nextDocument = createRes
                }
              } else {
                nextDocument = documentFileFromUriObj(findRes.uri, findRes.isDir)
              }

              if (nextDocument == null) {
                throw Exception("Failed to create directory at $curName")
              }
              if (nextDocument.isFile) {
                throw Exception("File found at $curName while creating directory")
              }
              curDocument = nextDocument
            }

            launch(Dispatchers.Main) {
              result.success(fileObjMapFromDocumentFile(curDocument))
            }
          } catch (err: Exception) {
            launch(Dispatchers.Main) {
              result.error("PluginError", err.message, null)
            }
          }
        }
      }

      "child" -> {
        CoroutineScope(Dispatchers.IO).launch {
          try {
            val uri = call.argument<String>("uri") as String
            val names = call.argument<ArrayList<String>>("names") as ArrayList<String>

            var curDocument = documentFileFromUri(uri, true) ?: throw Exception("Failed to get DocumentFile from $uri")
            for (curName in names) {
              val findRes = findDirectChild(curDocument.uri, curName)
              if (findRes == null) {
                launch(Dispatchers.Main) {
                  result.success(null)
                }
                return@launch
              }
              curDocument = documentFileFromUriObj(findRes.uri, findRes.isDir) ?: throw Exception("Failed to get DocumentFile at $curName")
            }

            launch(Dispatchers.Main) {
              result.success(fileObjMapFromDocumentFile(curDocument))
            }
          } catch (err: Exception) {
            launch(Dispatchers.Main) {
              result.error("PluginError", err.message, null)
            }
          }
        }
      }

      "rename" -> {
        CoroutineScope(Dispatchers.IO).launch {
          try {
            val uri = call.argument<String>("uri") as String
            val isDir = call.argument<Boolean>("isDir") as Boolean
            val newName = call.argument<String>("newName") as String

            val df = documentFileFromUri(uri, isDir) ?: throw Exception("Failed to get DocumentFile from $uri")
            if (isDir) {
              val success = df.renameTo(newName)
              if (!success) {
                throw Exception("Failed to rename to $newName")
              }
              launch(Dispatchers.Main) {
                result.success(fileObjMapFromDocumentFile(df))
              }
            } else {
              val newUri = renameFileDocumentFile(df, newName)
                ?: throw Exception("Failed to rename to $newName")
              val newDF = documentFileFromUriObj(newUri, false)
                ?: throw Exception("Failed to get DocumentFile from $newUri")
              launch(Dispatchers.Main) {
                result.success(fileObjMapFromDocumentFile(newDF))
              }
            }
          } catch (err: Exception) {
            launch(Dispatchers.Main) {
              result.error("PluginError", err.message, null)
            }
          }
        }
      }

      "moveTo" -> {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.N) {
          result.error("PluginError", "moveTo is only supported on Android N and above", null)
          return
        }
        CoroutineScope(Dispatchers.IO).launch {
          try {
            val uri = call.argument<String>("uri") as String
            val isDir = call.argument<Boolean>("isDir") as Boolean
            val parentUri = call.argument<String>("parentUri") as String
            val newParentUri = call.argument<String>("newParentUri") as String

            val uriObj = Uri.parse(uri)
            val parentUriObj = Uri.parse(parentUri)
            val newParentUriObj = Uri.parse(newParentUri)

            val resUri = DocumentsContract.moveDocument(
              context.contentResolver,
              uriObj,
              parentUriObj,
              newParentUriObj
            ) ?: throw Exception("Failed to move document")

            val resultDF = documentFileFromUriObj(resUri, isDir) ?: throw Exception("Failed to get DocumentFile from $resUri")
            launch(Dispatchers.Main) {
              result.success(fileObjMapFromDocumentFile(resultDF))
            }
          } catch (err: Exception) {
            launch(Dispatchers.Main) {
              result.error("PluginError", err.message, null)
            }
          }
        }
      }

      "copyTo" -> {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.N) {
          result.error("PluginError", "copyTo is only supported on Android N and above", null)
          return
        }
        CoroutineScope(Dispatchers.IO).launch {
          try {
            val uri = call.argument<String>("uri") as String
            val isDir = call.argument<Boolean>("isDir") as Boolean
            val newParentUri = call.argument<String>("newParentUri") as String

            val uriObj = Uri.parse(uri)
            val newParentUriObj = Uri.parse(newParentUri)

            val resUri = DocumentsContract.copyDocument(
              context.contentResolver,
              uriObj,
              newParentUriObj
            ) ?: throw Exception("Failed to move document")

            val resultDF = documentFileFromUriObj(resUri, isDir) ?: throw Exception("Failed to get DocumentFile from $resUri")

            launch(Dispatchers.Main) {
              result.success(fileObjMapFromDocumentFile(resultDF))
            }
          } catch (err: Exception) {
            launch(Dispatchers.Main) {
              result.error("PluginError", err.message, null)
            }
          }
        }
      }

      "openDirectory" -> {
        try {
          val initialUri = call.argument<String>("initialUri")
          val writePermission = call.argument<Boolean>("writePermission") ?: false
          val persistablePermission = call.argument<Boolean>("persistablePermission") ?: false

          if (activity == null) {
            result.error("NO_ACTIVITY", "Activity is null", null)
            return
          }
          if (pendingResult != null) {
            result.error("ALREADY_PICKING", "Another picker process is already in progress", null)
            return
          }

          // Store the result to return the URI later
          pendingResult = result
          pendingArguments = PendingDirArguments(writePermission, persistablePermission)
          val intent = Intent(Intent.ACTION_OPEN_DOCUMENT_TREE)
          if (initialUri != null) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
              intent.putExtra(DocumentsContract.EXTRA_INITIAL_URI, Uri.parse(initialUri))
            }
          }
          if (persistablePermission) {
            intent.addFlags(
              Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION
            )
          }
          intent.addFlags(
            if (writePermission) Intent.FLAG_GRANT_WRITE_URI_PERMISSION or Intent.FLAG_GRANT_READ_URI_PERMISSION
            else Intent.FLAG_GRANT_READ_URI_PERMISSION
          )

          activity?.startActivityForResult(intent, requestCodeOpenDocumentTree)
        } catch (err: Exception) {
          result.error("PluginError", err.message, null)
        }
      }

      "openFiles" -> {
        try {
          val initialUri = call.argument<String>("initialUri")
          val multiple = call.argument<Boolean>("multiple") ?: false
          val mimeTypes = call.argument<ArrayList<String>>("mimeTypes") ?: arrayListOf()

          if (activity == null) {
            result.error("NO_ACTIVITY", "Activity is null", null)
            return
          }
          if (pendingResult != null) {
            result.error("ALREADY_PICKING", "Another picker process is already in progress", null)
            return
          }

          // Store the result to return the URI later
          pendingResult = result
          val intent = Intent(Intent.ACTION_OPEN_DOCUMENT)
          intent.addCategory(Intent.CATEGORY_OPENABLE)
          if (initialUri != null) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
              intent.putExtra(DocumentsContract.EXTRA_INITIAL_URI, Uri.parse(initialUri))
            }
          }
          if (multiple) {
            intent.putExtra(Intent.EXTRA_ALLOW_MULTIPLE, true)
          }

          if (mimeTypes.isEmpty()) {
            intent.type = "*/*"
          } else if (mimeTypes.size == 1) {
            intent.type = mimeTypes[0]
          } else {
            intent.type = "*/*"
            intent.putExtra(Intent.EXTRA_MIME_TYPES, mimeTypes.toTypedArray())
          }

          activity?.startActivityForResult(intent, requestCodeOpenFiles)
        } catch (err: Exception) {
          result.error("PluginError", err.message, null)
        }
      }

      "saveThumbnailToFile" -> {
        CoroutineScope(Dispatchers.Default).launch {
          try {
            val uri = Uri.parse(call.argument("uri"))
            val dest = call.argument<String>("destPath")!!
            val format = call.argument<String>("format") ?: "jpeg"
            val isPng = format == "png"
            val quality = call.argument("quality") ?: if (isPng) 100 else 80

            val width = call.argument<Int>("width")!!
            val height = call.argument<Int>("height")!!

            val df = DocumentFile.fromSingleUri(context, uri)
            val mime = df?.type
            if (mime == null) {
              launch(Dispatchers.Main) {
                result.success(false)
              }
              return@launch
            }

            val bitmap: Bitmap?
            // Use MediaMetadataRetriever for video files.
            if (mime.startsWith("video/")) {
              val mmr = MediaMetadataRetriever()
              mmr.setDataSource(context, uri)
              bitmap = if (Build.VERSION.SDK_INT >= 27) {
                mmr.getScaledFrameAtTime(-1, OPTION_CLOSEST_SYNC, width, height)
              } else {
                mmr.frameAtTime
              }
            } else {
              // Use DocumentsContract for other files.
              bitmap = DocumentsContract.getDocumentThumbnail(
                context.contentResolver,
                uri,
                Point(width, height),
                null
              )
            }

            if (bitmap != null) {
              File(dest).writeBitmap(
                bitmap,
                if (isPng) Bitmap.CompressFormat.PNG else Bitmap.CompressFormat.JPEG,
                quality,
              )
              launch(Dispatchers.Main) {
                result.success(true)
              }
            } else {
              launch(Dispatchers.Main) {
                result.success(false)
              }
            }
          } catch (err: Exception) {
            launch(Dispatchers.Main) {
              result.error("PluginError", err.message, null)
            }
          }
        }
      }

      else -> result.notImplemented()
    }
  }

  // Handle the result of the folder picker
  private fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
    if (pendingResult == null) {
      return
    }
    try {
      if (requestCode == requestCodeOpenDocumentTree) {
        // Handle the result of the folder picker.
        if (resultCode == Activity.RESULT_OK && data != null) {
          val uri: Uri? = data.data
          if (uri != null && pendingArguments is PendingDirArguments) {
            val args = pendingArguments as PendingDirArguments
            if (args.persistablePermission) {
              context.contentResolver.takePersistableUriPermission(
                uri,
                if (args.writePermission) Intent.FLAG_GRANT_WRITE_URI_PERMISSION or Intent.FLAG_GRANT_READ_URI_PERMISSION
                else Intent.FLAG_GRANT_READ_URI_PERMISSION
              )
            }
          }
          pendingResult?.success(uri?.toString())  // Return the URI to Flutter
        } else {
          pendingResult?.success(null)
        }
      } else if (requestCode == requestCodeOpenFiles) {
        // Handle the result of file picker.
        if (resultCode == Activity.RESULT_OK && data != null) {
          val uris: List<Uri> = if (data.clipData != null) {
            val clipData = data.clipData
            val uris = mutableListOf<Uri>()
            for (i in 0 until clipData!!.itemCount) {
              uris.add(clipData.getItemAt(i).uri)
            }
            uris
          } else {
            listOf(data.data!!)
          }
          pendingResult?.success(uris.map { it.toString() })  // Return the URIs to Flutter
        } else {
          pendingResult?.success(null)
        }
      } else {
        // Ignore other requests.
        pendingResult?.success(null)
      }
    } catch (err: Exception) {
      pendingResult?.error("PluginError", err.message, null)
    }

    // Clear the pending result and arguments.
    pendingResult = null
    pendingArguments = null
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  private fun documentFileFromUri(uri: String, isDir: Boolean): DocumentFile? {
    val uriObj = Uri.parse(uri)
    return documentFileFromUriObj(uriObj, isDir)
  }

  private fun documentFileFromUriObj(uriObj: Uri, isDir: Boolean): DocumentFile? {
    val res = if (isDir) {
      DocumentFile.fromTreeUri(context, uriObj)
    } else {
      DocumentFile.fromSingleUri(context, uriObj)
    }
    return res
  }

  private fun findDirectChild(parentUri: Uri, name: String): UriInfo? {
    var cursor: Cursor? = null
    try {
      val resolver = context.contentResolver
      val childrenUri = DocumentsContract.buildChildDocumentsUriUsingTree(
        parentUri,
        DocumentsContract.getDocumentId(parentUri)
      )
      cursor = resolver.query(
        childrenUri,
        arrayOf(
          DocumentsContract.Document.COLUMN_DOCUMENT_ID,
          DocumentsContract.Document.COLUMN_DISPLAY_NAME,
          DocumentsContract.Document.COLUMN_MIME_TYPE,
        ),
        null,
        null,
        null
      )

      while (cursor?.moveToNext() == true) {
        val documentId = cursor.getString(0)
        val fileName = cursor.getString(1)
        val mimeType = cursor.getString(2)
        val isDirectory = DocumentsContract.Document.MIME_TYPE_DIR == mimeType

        if (fileName == name) {
          val documentUri = DocumentsContract.buildDocumentUriUsingTree(parentUri, documentId)
          return UriInfo(documentUri, fileName, isDirectory)
        }
      }
      return null
    } finally {
      try {
        cursor?.close()
      } catch (_: Exception) {
      }
    }
  }

  private fun renameFileDocumentFile(df: DocumentFile, newName: String): Uri? {
    // https://cs.android.com/androidx/platform/frameworks/support/+/androidx-main:documentfile/documentfile/src/main/java/androidx/documentfile/provider/TreeDocumentFile.java
    try {
      val result = DocumentsContract.renameDocument(
        context.contentResolver, df.uri, newName
      )
      return result
    } catch (err: Exception) {
      return null
    }
  }

  private fun fileObjMapFromDocumentFile(file: DocumentFile): Map<String, Any?> {
    return fileObjMap(
      file.uri,
      file.isDirectory,
      file.name ?: "",
      file.length().toInt(),
      file.lastModified(),
    )
  }

  private fun fileObjMap(
    uri: Uri,
    isDir: Boolean,
    name: String,
    length: Int,
    lastMod: Long,
  ): Map<String, Any?> {
    return mapOf(
      "uri" to uri.toString(),
      "isDir" to isDir,
      "name" to name,
      "length" to length,
      "lastModified" to lastMod,
    )
  }

  private fun File.writeBitmap(bitmap: Bitmap, format: Bitmap.CompressFormat, quality: Int) {
    outputStream().use { out ->
      bitmap.compress(format, quality, out)
      out.flush()
    }
  }
}

internal data class UriInfo(val uri: Uri, val name: String, val isDir: Boolean)

internal open class PendingArguments

internal class PendingDirArguments(
  val writePermission: Boolean,
  val persistablePermission: Boolean,
): PendingArguments()