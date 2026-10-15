package net.wiseless.wisetalk

import android.media.AudioAttributes
import android.media.AudioFormat
import android.media.AudioTrack
import android.media.audiofx.AcousticEchoCanceler
import android.media.audiofx.NoiseSuppressor
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

    override fun onDestroy() {
        // The call lives in this activity's engine: it ends with it.
        if (isFinishing) CallService.stop(this)
        super.onDestroy()
    }
}
