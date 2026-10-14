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
 */
class CallService : Service() {
    companion object {
        private const val TAG = "CallService"
        private const val CHANNEL = "call"
        private const val NOTIFICATION = 1
        private const val TITLE = "title"
        private const val SHARING = "sharing"

        /** Answers the latest [update] once the service is in the foreground. */
        private var pending: ((Boolean) -> Unit)? = null

        private fun types(context: Context, sharing: Boolean): Int {
            var types = 0
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
         * [title]; [done] gets whether it runs. Screen capture may start only
         * after the system's consent and once this ran with [sharing].
         */
        fun update(context: Context, title: String, sharing: Boolean, done: (Boolean) -> Unit) {
            // Without the microphone and not sharing there is nothing to keep.
            if (types(context, sharing) == 0) {
                stop(context)
                return done(false)
            }
            pending?.invoke(false)
            pending = done
            try {
                context.startForegroundService(
                    Intent(context, CallService::class.java)
                        .putExtra(TITLE, title)
                        .putExtra(SHARING, sharing),
                )
            } catch (e: Exception) {
                Log.w(TAG, "cannot start: $e")
                pending = null
                done(false)
            }
        }

        fun stop(context: Context) {
            context.stopService(Intent(context, CallService::class.java))
        }
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val title = intent?.getStringExtra(TITLE) ?: "Wisetalk"
        val sharing = intent?.getBooleanExtra(SHARING, false) ?: false
        val ok = try {
            startForeground(NOTIFICATION, notification(title, sharing), types(this, sharing))
            true
        } catch (e: Exception) {
            Log.w(TAG, "cannot go to the foreground: $e")
            stopSelf()
            false
        }
        pending?.invoke(ok)
        pending = null
        return START_NOT_STICKY
    }

    // Swiped away from the recent apps: the call ends with the app.
    override fun onTaskRemoved(rootIntent: Intent?) {
        stopSelf()
    }

    private fun notification(title: String, sharing: Boolean): Notification {
        val manager = getSystemService(NotificationManager::class.java)
        manager.createNotificationChannel(
            NotificationChannel(CHANNEL, "Calls", NotificationManager.IMPORTANCE_LOW),
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
            .setContentText(if (sharing) "Sharing your screen" else "In a voice call")
            .setContentIntent(open)
            .setOngoing(true)
            .setCategory(Notification.CATEGORY_CALL)
            .build()
    }
}
