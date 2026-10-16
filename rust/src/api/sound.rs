//! Owl hoots and shortcut ticks on the output the call plays on (WLK-8).
//! audioplayers only knows the system's default output, so with headphones
//! picked in Settings the voices went to them and the owl to the speakers.
//! The app makes the PCM itself (`lib/data/sounds.dart`) and hands it here
//! with the output it gave the call.

/// Plays 16-bit little-endian mono `pcm` at `rate` on `device`, an output
/// id as flutter_webrtc lists it (`None` for the system's default), and
/// returns once it has played: through PulseAudio on Linux, WASAPI on
/// Windows and CoreAudio on macOS. `false` when that didn't work, or on
/// phones, and the app should play it as before. An output that went away
/// plays on the default one.
pub fn play_sound(pcm: Vec<u8>, rate: u32, device: Option<String>) -> bool {
    crate::sound::play(&pcm, rate, device.as_deref())
}
