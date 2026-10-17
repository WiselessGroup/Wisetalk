package net.wiseless.wisetalk

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/** Brings Stay Connected back after a restart of the phone or an update of Wisetalk. */
class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            Intent.ACTION_BOOT_COMPLETED,
            Intent.ACTION_MY_PACKAGE_REPLACED,
            -> StayConnectedService.resume(context)
        }
    }
}
