package net.wiseless.wisetalk

import android.content.Context
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel

/**
 * The process's one Flutter engine. It belongs to the process, not to
 * MainActivity, so that with Stay Connected on the gateway connection in
 * Dart outlives the activity: swiped away from the recent apps, Wisetalk
 * still hears summons (ADR-0035). Without StayConnectedService running,
 * the activity destroys it with itself, as before.
 */
object WisetalkEngine {
    /** What `main` gets when the engine starts without a window (lib/main.dart). */
    private const val BACKGROUND_ARGUMENT = "--background"

    private var engine: FlutterEngine? = null
    private var channel: MethodChannel? = null

    /**
     * The running engine, or a new one running `main`: [background] when
     * the system started Wisetalk for the service, with no window to show.
     */
    fun get(context: Context, background: Boolean): FlutterEngine {
        engine?.let { return it }
        val app = context.applicationContext
        val created = FlutterEngine(app)
        created.addEngineLifecycleListener(
            object : FlutterEngine.EngineLifecycleListener {
                override fun onPreEngineRestart() {}

                override fun onEngineWillDestroy() {
                    if (engine === created) {
                        engine = null
                        channel = null
                    }
                }
            },
        )
        // lib/data/stay_connected.dart
        channel = MethodChannel(created.dartExecutor.binaryMessenger, "net.wiseless.wisetalk/background")
            .apply { setMethodCallHandler { call, result -> StayConnectedService.handle(app, call, result) } }
        created.dartExecutor.executeDartEntrypoint(
            DartExecutor.DartEntrypoint.createDefault(),
            if (background) listOf(BACKGROUND_ARGUMENT) else emptyList(),
        )
        engine = created
        return created
    }

    /** Tells Dart about [method]; on the main thread only. */
    fun tell(method: String, arguments: Any? = null) {
        channel?.invokeMethod(method, arguments)
    }
}
