package com.linki.linki

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    companion object {
        private const val CHANNEL = "linki/file"
        private const val CREATE_FILE_REQUEST = 1001
    }

    private var pendingContent: String? = null

    override fun configureFlutterEngine(
        @NonNull flutterEngine: FlutterEngine
    ) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->

            when (call.method) {
                "saveFile" -> {
                    val content = call.argument<String>("content")

                    if (content == null) {
                        result.error(
                            "INVALID_CONTENT",
                            "File content is missing",
                            null
                        )
                        return@setMethodCallHandler
                    }

                    pendingContent = content

                    val intent = Intent(
                        Intent.ACTION_CREATE_DOCUMENT
                    ).apply {
                        addCategory(
                            Intent.CATEGORY_OPENABLE
                        )
                        type = "text/plain"
                        putExtra(
                            Intent.EXTRA_TITLE,
                            "linki.txt"
                        )
                    }

                    startActivityForResult(
                        intent,
                        CREATE_FILE_REQUEST
                    )

                    result.success(true)
                }

                else -> result.notImplemented()
            }
        }
    }

    override fun onActivityResult(
        requestCode: Int,
        resultCode: Int,
        data: Intent?
    ) {
        super.onActivityResult(
            requestCode,
            resultCode,
            data
        )

        if (requestCode != CREATE_FILE_REQUEST) {
            return
        }

        if (
            resultCode == Activity.RESULT_OK &&
            data?.data != null
        ) {
            val uri = data.data!!

            try {
                contentResolver.openOutputStream(uri)
                    ?.use { output ->
                        output.write(
                            pendingContent
                                ?.toByteArray(Charsets.UTF_8)
                                ?: ByteArray(0)
                        )
                    }
            } catch (_: Exception) {
                // Ignore for now.
            }
        }

        pendingContent = null
    }
}
