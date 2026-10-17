package net.wiseless.wisetalk

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.net.ConnectivityManager
import android.net.Network
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.os.PowerManager
import android.provider.Settings
import android.util.Log
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Stay Connected (ADR-0035): keeps the process, and with it the Dart
 * gateway connection in [WisetalkEngine], alive while Wisetalk is closed,
 * so summons arrive without Google or a push app. A quiet ongoing
 * notification, as Android wants for this. Of type `specialUse`, as ntfy
 * and Conversations do: `dataSync` stops after six hours a day on Android
 * 15, and `remoteMessaging` is meant for handing messages between devices.
 *
 * It reconnects nothing on a timer: it tells Dart when the phone's network
 * changes, and Dart reconnects then. The system restarts it after killing
 * the process, after a restart of the phone and after an update
 * ([BootReceiver]), as long as it was on.
 */
class StayConnectedService : Service() {
    companion object {
        private const val TAG = "StayConnected"
        private const val CHANNEL = "connected"
        private const val NOTIFICATION = 2
        private const val PREFERENCES = "stay_connected"
        private const val ON = "on"
        private const val TITLE = "title"
        private const val TEXT = "text"
        private const val CHANNEL_NAME = "channelName"

        /** While it runs the engine outlives MainActivity. */
        @Volatile
        var running = false
            private set

        /** lib/data/stay_connected.dart */
        fun handle(context: Context, call: MethodCall, result: MethodChannel.Result) {
            when (call.method) {
                "start" -> result.success(
                    start(
                        context,
                        call.argument<String>("title") ?: "Wisetalk",
                        call.argument<String>("text") ?: "",
                        call.argument<String>("channelName") ?: "Wisetalk",
                    ),
                )
                "stop" -> {
                    stop(context)
                    result.success(null)
                }
                "batteryExempt" -> result.success(
                    context.getSystemService(PowerManager::class.java)
                        .isIgnoringBatteryOptimizations(context.packageName),
                )
                "askBattery" -> result.success(askBattery(context))
                "manufacturer" -> result.success(Build.MANUFACTURER)
                else -> result.notImplemented()
            }
        }

        private fun preferences(context: Context) =
            context.getSharedPreferences(PREFERENCES, Context.MODE_PRIVATE)

        /**
         * Runs it from now on, and after restarts of the phone, with its
         * notification in the app's language: Android has no strings of
         * its own here, the texts are kept for when Dart isn't running yet.
         */
        private fun start(context: Context, title: String, text: String, channelName: String): Boolean {
            preferences(context).edit()
                .putBoolean(ON, true)
                .putString(TITLE, title)
                .putString(TEXT, text)
                .putString(CHANNEL_NAME, channelName)
                .apply()
            return launch(context)
        }

        private fun stop(context: Context) {
            preferences(context).edit().putBoolean(ON, false).apply()
            context.stopService(Intent(context, StayConnectedService::class.java))
        }

        /** After a restart of the phone or an update: again, if it was on. */
        fun resume(context: Context) {
            if (preferences(context).getBoolean(ON, false)) launch(context)
        }

        private fun launch(context: Context): Boolean = try {
            context.startForegroundService(Intent(context, StayConnectedService::class.java))
            true
        } catch (e: Exception) {
            // Started from the background without an exemption, say.
            Log.w(TAG, "cannot start: $e")
            false
        }

        /** The system's question about battery optimization, once asked in Dart. */
        private fun askBattery(context: Context): Boolean = try {
            context.startActivity(
                Intent(
                    Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS,
                    Uri.parse("package:${context.packageName}"),
                ).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK),
            )
            true
        } catch (e: Exception) {
            Log.w(TAG, "cannot ask about the battery: $e")
            false
        }
    }

    private var network: ConnectivityManager.NetworkCallback? = null

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        running = true
        // Started by the system, after the process was gone: Dart starts
        // without a window and connects in the background.
        WisetalkEngine.get(this, background = true)
        watchNetwork()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val preferences = preferences(this)
        // Android wants the notification up before anything else, even
        // from a service about to stop.
        try {
            val notification = notification(
                preferences.getString(TITLE, null) ?: "Wisetalk",
                preferences.getString(TEXT, null) ?: "",
                preferences.getString(CHANNEL_NAME, null) ?: "Wisetalk",
            )
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
                startForeground(NOTIFICATION, notification, ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE)
            } else {
                startForeground(NOTIFICATION, notification)
            }
        } catch (e: Exception) {
            Log.w(TAG, "cannot go to the foreground: $e")
            stopSelf()
            return START_NOT_STICKY
        }
        if (!preferences.getBoolean(ON, false)) {
            stopSelf()
            return START_NOT_STICKY
        }
        return START_STICKY
    }

    // Swiped away from the recent apps: the point is to stay.
    override fun onTaskRemoved(rootIntent: Intent?) {}

    override fun onDestroy() {
        running = false
        network?.let { getSystemService(ConnectivityManager::class.java).unregisterNetworkCallback(it) }
        network = null
        super.onDestroy()
    }

    /**
     * Tells Dart when the network the phone uses changes or goes: a
     * connection over the one before is gone, even if nothing said so.
     */
    private fun watchNetwork() {
        val main = Handler(Looper.getMainLooper())
        val callback = object : ConnectivityManager.NetworkCallback() {
            private var first = true
            private var current: Network? = null

            override fun onAvailable(network: Network) {
                // The first call only names the network there already is.
                val changed = !first && network != current
                first = false
                current = network
                if (changed) main.post { WisetalkEngine.tell("network", true) }
            }

            override fun onLost(network: Network) {
                if (network != current) return
                current = null
                main.post { WisetalkEngine.tell("network", false) }
            }
        }
        try {
            getSystemService(ConnectivityManager::class.java).registerDefaultNetworkCallback(callback)
            network = callback
        } catch (e: Exception) {
            Log.w(TAG, "cannot watch the network: $e")
        }
    }

    private fun notification(title: String, text: String, channelName: String): Notification {
        val manager = getSystemService(NotificationManager::class.java)
        // The quietest there is: no sound, no icon in the status bar,
        // folded at the bottom of the shade.
        manager.createNotificationChannel(
            NotificationChannel(CHANNEL, channelName, NotificationManager.IMPORTANCE_MIN),
        )
        val open = PendingIntent.getActivity(
            this,
            0,
            packageManager.getLaunchIntentForPackage(packageName),
            PendingIntent.FLAG_IMMUTABLE,
        )
        return Notification.Builder(this, CHANNEL)
            .setSmallIcon(R.drawable.ic_call_notification)
            .setContentTitle(title)
            .setContentText(text)
            .setContentIntent(open)
            .setOngoing(true)
            .setShowWhen(false)
            .setCategory(Notification.CATEGORY_SERVICE)
            .build()
    }
}
