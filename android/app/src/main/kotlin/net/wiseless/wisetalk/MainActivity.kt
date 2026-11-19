package net.wiseless.wisetalk

import android.app.PictureInPictureParams
import android.content.Context
import android.content.res.Configuration
import android.media.AudioAttributes
import android.media.AudioFormat
import android.media.AudioTrack
import android.media.audiofx.AcousticEchoCanceler
import android.media.audiofx.NoiseSuppressor
import android.os.Build
import android.util.Log
import android.util.Rational
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    // The process's engine, which may already run for Stay Connected.
    override fun provideFlutterEngine(context: Context): FlutterEngine =
        WisetalkEngine.get(context, background = false)

    // With Stay Connected the engine, and the connection in it, outlive
    // the window; without it they end with it, as before.
    override fun shouldDestroyEngineWithHost(): Boolean = !StayConnectedService.running

    /**
     * Someone shares a screen in the call: leaving Wisetalk shrinks it to a
     * small window over the other apps, with the share alone in it
     * (lib/data/picture_in_picture.dart, WLK-63).
     */
    private var pipWanted = false
    private var pipChannel: MethodChannel? = null

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
                            result.success(0)
                        } else {
                            val sharing = call.argument<Boolean>("sharing") ?: false
                            // In the app's language, which may not be the system's.
                            val text = call.argument<String>("text") ?: ""
                            val channelName = call.argument<String>("channelName") ?: "Calls"
                            CallService.update(this, title, text, channelName, sharing) {
                                result.success(it)
                            }
                        }
                    }
                    else -> result.notImplemented()
                }
            }
        // lib/data/picture_in_picture.dart
        pipChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "net.wiseless.wisetalk/pip")
            .also {
                it.setMethodCallHandler { call, result ->
                    when (call.method) {
                        "want" -> {
                            pipWanted = call.argument<Boolean>("on") ?: false
                            try {
                                setPictureInPictureParams(pipParams())
                            } catch (e: Exception) {
                                Log.w("PictureInPicture", "cannot set it up: $e")
                            }
                            result.success(null)
                        }
                        else -> result.notImplemented()
                    }
                }
            }
        // lib/data/input_filters.dart: WebRTC uses the phone's own echo
        // cancellation and noise suppression when it has both.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "net.wiseless.wisetalk/audio")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "filtersInput" -> result.success(
                        AcousticEchoCanceler.isAvailable() && NoiseSuppressor.isAvailable(),
                    )
                    else -> result.notImplemented()
                }
            }
        // lib/data/screen_sound.dart
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "net.wiseless.wisetalk/screen_sound")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "start" -> {
                        val track = call.argument<String>("track")
                        result.success(track != null && ScreenSound.start(this, track))
                    }
                    "microphone" -> {
                        ScreenSound.microphone = call.argument<Boolean>("on") ?: true
                        result.success(null)
                    }
                    "stop" -> {
                        ScreenSound.stop()
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
        // lib/data/sounds.dart
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "net.wiseless.wisetalk/sound")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "play" -> {
                        val pcm = call.argument<ByteArray>("pcm")
                        val rate = call.argument<Int>("rate")
                        if (pcm != null && rate != null) play(pcm, rate)
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    /**
     * Plays a short 16-bit mono sound as part of the call: on the call's
     * route (earpiece, speaker or headset), taking no audio focus and
     * leaving the audio mode alone.
     */
    private fun play(pcm: ByteArray, rate: Int) {
        try {
            val track = AudioTrack.Builder()
                .setAudioAttributes(
                    AudioAttributes.Builder()
                        .setUsage(AudioAttributes.USAGE_VOICE_COMMUNICATION)
                        .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                        .build(),
                )
                .setAudioFormat(
                    AudioFormat.Builder()
                        .setEncoding(AudioFormat.ENCODING_PCM_16BIT)
                        .setSampleRate(rate)
                        .setChannelMask(AudioFormat.CHANNEL_OUT_MONO)
                        .build(),
                )
                .setBufferSizeInBytes(pcm.size)
                .setTransferMode(AudioTrack.MODE_STATIC)
                .build()
            track.write(pcm, 0, pcm.size)
            track.notificationMarkerPosition = pcm.size / 2 - 1
            track.setPlaybackPositionUpdateListener(
                object : AudioTrack.OnPlaybackPositionUpdateListener {
                    override fun onMarkerReached(played: AudioTrack) = played.release()
                    override fun onPeriodicNotification(played: AudioTrack) {}
                },
            )
            track.play()
        } catch (e: Exception) {
            android.util.Log.w("Sounds", "a sound cue did not play: $e")
        }
    }

    private fun pipParams(): PictureInPictureParams {
        val params = PictureInPictureParams.Builder().setAspectRatio(Rational(16, 9))
        // Android 12 and later go into it by themselves, smoothly.
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) params.setAutoEnterEnabled(pipWanted)
        return params.build()
    }

    // Android 11 has no going in by itself: going home is the cue.
    override fun onUserLeaveHint() {
        super.onUserLeaveHint()
        if (pipWanted && Build.VERSION.SDK_INT < Build.VERSION_CODES.S) {
            try {
                enterPictureInPictureMode(pipParams())
            } catch (e: Exception) {
                Log.w("PictureInPicture", "cannot go into it: $e")
            }
        }
    }

    override fun onPictureInPictureModeChanged(inPip: Boolean, newConfig: Configuration) {
        super.onPictureInPictureModeChanged(inPip, newConfig)
        pipChannel?.invokeMethod("changed", inPip)
    }

    override fun onDestroy() {
        // Closing Wisetalk ends the call, also when the engine stays for
        // Stay Connected: the microphone can't go on without the window.
        if (isFinishing) {
            ScreenSound.stop()
            CallService.stop(this)
            if (StayConnectedService.running) WisetalkEngine.tell("closed")
        }
        super.onDestroy()
    }
}
