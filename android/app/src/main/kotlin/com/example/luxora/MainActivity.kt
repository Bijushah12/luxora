package com.example.luxora

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "luxora/share")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "shareText" -> {
                        val text = call.argument<String>("text").orEmpty()
                        val title = call.argument<String>("title") ?: "Share with"

                        if (text.isBlank()) {
                            result.error("EMPTY_SHARE_TEXT", "Nothing to share.", null)
                            return@setMethodCallHandler
                        }

                        val sendIntent = Intent(Intent.ACTION_SEND).apply {
                            type = "text/plain"
                            putExtra(Intent.EXTRA_TEXT, text)
                            putExtra(Intent.EXTRA_SUBJECT, title)
                        }

                        startActivity(Intent.createChooser(sendIntent, title))
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
