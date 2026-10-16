package net.wiseless.wisetalk

import android.Manifest
import android.annotation.SuppressLint
import android.content.Context
import android.content.pm.PackageManager
import android.media.AudioAttributes
import android.media.AudioFormat
import android.media.AudioPlaybackCaptureConfiguration
import android.media.AudioRecord
import android.media.projection.MediaProjection
import android.os.Handler
import android.os.Looper
import android.os.Process
import android.util.Log
import com.cloudwebrtc.webrtc.FlutterWebRTCPlugin
import com.cloudwebrtc.webrtc.audio.AudioProcessingAdapter
import java.nio.ByteBuffer
import java.nio.ByteOrder

/**
 * The shared screen's sound on Android (WLK-3, lib/data/screen_sound.dart):
 * what other apps play, recorded through the screen share's MediaProjection,
 * mixed into what the microphone sends after WebRTC has cleaned the voice
 * up. Wisetalk's own sound stays out, the call's voices with it.
 *
 * flutter_webrtc on Android records from one place, the microphone, and
 * every audio track it makes carries that: the sound can't have a track of
 * its own. With the microphone off it goes alone, through a track the app
 * publishes as the screen's sound, and the microphone is silenced here.
 *
 * Costs nothing outside a share with sound: the processor is in WebRTC's
 * chain only while it runs.
 */
object ScreenSound : AudioProcessingAdapter.ExternalAudioFrameProcessing {
    private const val TAG = "ScreenSound"

    /** Sound buffered before it starts or after it ran dry, against gaps. */
    private const val PRIMED_MS = 40

    /** More than this waiting means the clocks drifted: the oldest goes. */
    private const val MOST_MS = 200

    /** Whether the voice goes out too, or the screen's sound alone. */
    @Volatile
    var microphone = true

    /** WebRTC's capture rate, which the recording follows. */
    @Volatile
    private var rate = 48000

    private var capture: Capture? = null
    private var projection: MediaProjection? = null
    private val main = Handler(Looper.getMainLooper())

    private val stopped = object : MediaProjection.Callback() {
        override fun onStop() = stop()
    }

    // Filled by the recording, emptied by WebRTC every 10 ms.
    private val lock = Object()
    private var ring = FloatArray(0)
    private var start = 0
    private var size = 0
    private var primed = false
    private var scratch = FloatArray(0)

    /**
     * Starts recording what the phone plays, for the screen share whose
     * video track is [trackId]; whether it runs. Needs the microphone
     * permission, as all recording does.
     */
    fun start(context: Context, trackId: String): Boolean {
        stop()
        if (context.checkSelfPermission(Manifest.permission.RECORD_AUDIO) !=
            PackageManager.PERMISSION_GRANTED
        ) {
            Log.w(TAG, "no microphone permission")
            return false
        }
        val found = try {
            projectionOf(trackId)
        } catch (e: Exception) {
            Log.w(TAG, "cannot reach the screen share: $e")
            null
        } ?: return false
        val controller = FlutterWebRTCPlugin.sharedSingleton?.audioProcessingController
            ?: return false
        val config = try {
            AudioPlaybackCaptureConfiguration.Builder(found)
                .addMatchingUsage(AudioAttributes.USAGE_MEDIA)
                .addMatchingUsage(AudioAttributes.USAGE_GAME)
                .addMatchingUsage(AudioAttributes.USAGE_UNKNOWN)
                .excludeUid(Process.myUid())
                .build()
        } catch (e: Exception) {
            Log.w(TAG, "cannot record the screen's sound: $e")
            return false
        }
        synchronized(lock) {
            size = 0
            primed = false
        }
        found.registerCallback(stopped, main)
        projection = found
        capture = Capture(config).also { it.start() }
        controller.capturePostProcessing.addProcessor(this)
        Log.i(TAG, "started")
        return true
    }

    fun stop() {
        val running = capture ?: return
        FlutterWebRTCPlugin.sharedSingleton?.audioProcessingController
            ?.capturePostProcessing?.removeProcessor(this)
        projection?.unregisterCallback(stopped)
        projection = null
        running.finish()
        capture = null
        microphone = true
        Log.i(TAG, "stopped")
    }

    /**
     * The MediaProjection that flutter_webrtc's screen capturer holds, kept
     * private there: Android 14 grants one per consent, so the sound can't
     * ask for its own. Its classes keep their names (its ProGuard rules).
     */
    private fun projectionOf(trackId: String): MediaProjection? {
        val plugin = FlutterWebRTCPlugin.sharedSingleton ?: return null
        val capturers = plugin.field("methodCallHandler")
            ?.field("getUserMediaImpl")
            ?.field("mVideoCapturers") as? Map<*, *> ?: return null
        return capturers[trackId]?.field("capturer")?.field("mediaProjection") as? MediaProjection
    }

    private fun Any.field(name: String): Any? {
        var type: Class<*>? = javaClass
        while (type != null) {
            try {
                return type.getDeclaredField(name).apply { isAccessible = true }.get(this)
            } catch (_: NoSuchFieldException) {
                type = type.superclass
            }
        }
        throw NoSuchFieldException(name)
    }

    override fun initialize(sampleRateHz: Int, numChannels: Int) {
        rate = sampleRateHz
    }

    override fun reset(newRate: Int) {
        rate = newRate
    }

    /**
     * One channel of 10 ms, floats on the 16-bit scale; the voice in it
     * already cleaned up.
     */
    override fun process(numBands: Int, numFrames: Int, buffer: ByteBuffer) {
        // Added after WebRTC set up, this was never initialized: the rate
        // comes from the frame, 10 ms of it.
        if (numFrames * 100 != rate) rate = numFrames * 100
        val samples = buffer.order(ByteOrder.nativeOrder()).asFloatBuffer()
        val count = minOf(numFrames, samples.capacity())
        if (scratch.size < count) scratch = FloatArray(count)
        take(scratch, count)
        val voice = microphone
        for (i in 0 until count) {
            val mixed = scratch[i] + if (voice) samples.get(i) else 0f
            samples.put(i, mixed.coerceIn(-32768f, 32767f))
        }
    }

    /** Fills [into] with what was recorded, silence where nothing was. */
    private fun take(into: FloatArray, count: Int) {
        synchronized(lock) {
            if (!primed && size >= rate * PRIMED_MS / 1000) primed = true
            var taken = 0
            if (primed) {
                taken = minOf(count, size)
                for (i in 0 until taken) into[i] = ring[(start + i) % ring.size]
                start = (start + taken) % ring.size
                size -= taken
                // Ran dry: wait for some sound again rather than crackle.
                if (taken < count) primed = false
            }
            into.fill(0f, taken, count)
        }
    }

    private fun put(from: ShortArray, count: Int, sampleRate: Int) {
        synchronized(lock) {
            val capacity = sampleRate * MOST_MS / 1000
            if (ring.size != capacity) {
                ring = FloatArray(capacity)
                start = 0
                size = 0
                primed = false
            }
            for (i in 0 until count) {
                if (size == capacity) {
                    start = (start + 1) % capacity
                    size--
                }
                ring[(start + size) % capacity] = from[i].toFloat()
                size++
            }
        }
    }

    /** Records on a thread of its own, at whatever rate WebRTC runs. */
    private class Capture(private val config: AudioPlaybackCaptureConfiguration) :
        Thread("ScreenSound") {
        @Volatile
        private var running = true

        @Volatile
        private var record: AudioRecord? = null

        fun finish() {
            running = false
            // Wakes a read waiting for sound.
            try {
                record?.stop()
            } catch (_: IllegalStateException) {
            }
            join(500)
        }

        @SuppressLint("MissingPermission") // Checked in start().
        private fun open(sampleRate: Int): AudioRecord {
            val format = AudioFormat.Builder()
                .setEncoding(AudioFormat.ENCODING_PCM_16BIT)
                .setSampleRate(sampleRate)
                .setChannelMask(AudioFormat.CHANNEL_IN_MONO)
                .build()
            val least = AudioRecord.getMinBufferSize(
                sampleRate,
                AudioFormat.CHANNEL_IN_MONO,
                AudioFormat.ENCODING_PCM_16BIT,
            )
            return AudioRecord.Builder()
                .setAudioFormat(format)
                .setAudioPlaybackCaptureConfig(config)
                .setBufferSizeInBytes(maxOf(least, sampleRate / 10 * 2))
                .build()
        }

        override fun run() {
            Process.setThreadPriority(Process.THREAD_PRIORITY_URGENT_AUDIO)
            try {
                while (running) {
                    val sampleRate = rate
                    val opened = open(sampleRate)
                    record = opened
                    opened.startRecording()
                    val chunk = ShortArray(sampleRate / 100)
                    while (running && rate == sampleRate) {
                        val read = opened.read(chunk, 0, chunk.size)
                        if (read < 0) {
                            Log.w(TAG, "recording ended: $read")
                            running = false
                        } else if (read > 0) {
                            put(chunk, read, sampleRate)
                        }
                    }
                    record = null
                    opened.release()
                }
            } catch (e: Exception) {
                Log.w(TAG, "cannot record the screen's sound: $e")
            }
        }
    }
}
