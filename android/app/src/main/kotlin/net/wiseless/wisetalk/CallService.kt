package net.wiseless.wisetalk

import android.Manifest
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.content.pm.ServiceInfo
import android.os.IBinder
import android.util.Log

/**
 * Keeps a call going while Wisetalk is in the background, with an ongoing
 * notification. Android stops the microphone of an app that goes to the
 * background without one, and screen capture needs one of its own type.
 * Someone who only listens has no microphone permission and still needs
 * the call kept: the phone call type covers that (WLK-64).
 */
class CallService : Service() {
    companion object {
        private const val TAG = "CallService"
        private const val CHANNEL = "call"
        private const val NOTIFICATION = 1
        private const val TITLE = "title"
        private const val TEXT = "text"
        private const val CHANNEL_NAME = "channelName"
        private const val SHARING = "sharing"

        /** Answers the latest [update] once the service is in the foreground. */
        private var pending: ((Int) -> Unit)? = null

        private fun types(context: Context, sharing: Boolean): Int {
            var types = ServiceInfo.FOREGROUND_SERVICE_TYPE_PHONE_CALL
            if (context.checkSelfPermission(Manifest.permission.RECORD_AUDIO) ==
                PackageManager.PERMISSION_GRANTED
            ) {
                types = types or ServiceInfo.FOREGROUND_SERVICE_TYPE_MICROPHONE
            }
            if (sharing) types = types or ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PROJECTION
            return types
        }

        /**
         * Starts the service, or changes what it says and does, for a call in
         * [title], with [text] under it and its notification channel called
         * [channelName]; [done] gets whether it runs. Screen capture may start
         * only after the system's consent and once this ran with [sharing].
         * [done] gets the types it runs with, 0 when it doesn't run.
         */
        fun update(
            context: Context,
            title: String,
            text: String,
            channelName: String,
            sharing: Boolean,
            done: (Int) -> Unit,
        ) {
            pending?.invoke(0)
            pending = done
            try {
                context.startForegroundService(
                    Intent(context, CallService::class.java)
                        .putExtra(TITLE, title)
                        .putExtra(TEXT, text)
                        .putExtra(CHANNEL_NAME, channelName)
                        .putExtra(SHARING, sharing),
                )
            } catch (e: Exception) {
                Log.w(TAG, "cannot start: $e")
                pending = null
                done(0)
            }
        }

        fun stop(context: Context) {
            context.stopService(Intent(context, CallService::class.java))
        }
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val title = intent?.getStringExtra(TITLE) ?: "Wisetalk"
        val text = intent?.getStringExtra(TEXT) ?: ""
        val channelName = intent?.getStringExtra(CHANNEL_NAME) ?: "Calls"
        val sharing = intent?.getBooleanExtra(SHARING, false) ?: false
        val types = types(this, sharing)
        val ok = try {
            startForeground(NOTIFICATION, notification(title, text, channelName), types)
            types
        } catch (e: Exception) {
            Log.w(TAG, "cannot go to the foreground: $e")
            stopSelf()
            0
        }
        pending?.invoke(ok)
        pending = null
        return START_NOT_STICKY
    }

    // Swiped away from the recent apps: the call ends with the app.
    override fun onTaskRemoved(rootIntent: Intent?) {
        stopSelf()
    }

    private fun notification(title: String, text: String, channelName: String): Notification {
        val manager = getSystemService(NotificationManager::class.java)
        // Creating it again renames it, after a change of language.
        manager.createNotificationChannel(
            NotificationChannel(CHANNEL, channelName, NotificationManager.IMPORTANCE_LOW),
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
            .setCategory(Notification.CATEGORY_CALL)
            .build()
    }
}
