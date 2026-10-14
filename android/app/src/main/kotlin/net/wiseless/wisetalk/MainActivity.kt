package net.wiseless.wisetalk

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // lib/data/call_service.dart
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "net.wiseless.wisetalk/call")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "update" -> {
                        val title = call.argument<String>("title")
                        if (title == null) {
                            CallService.stop(this)
                            result.success(false)
                        } else {
                            val sharing = call.argument<Boolean>("sharing") ?: false
                            CallService.update(this, title, sharing) { result.success(it) }
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    override fun onDestroy() {
        // The call lives in this activity's engine: it ends with it.
        if (isFinishing) CallService.stop(this)
        super.onDestroy()
    }
}
