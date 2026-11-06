//! A shared screen's sound on Linux without the call's own voices in it
//! (see `screen_sound.rs` beside `api`). Elsewhere these do nothing and
//! return `false`: Windows and Android leave Wisetalk out on their own.

/// Sets up the mix of every other app's sound, before the share starts.
/// `false` when there is no PulseAudio or PipeWire to do it with: then the
/// share must go without sound, or the call would be in it.
pub fn screen_sound_start() -> bool {
    crate::screen_sound::start()
}

/// After the share has started: waits up to `timeout_ms` for
/// flutter_webrtc's recording to be moved onto the mix. `false` means it
/// still records the speakers, call and all, so its track must not go out.
pub fn screen_sound_attached(timeout_ms: u32) -> bool {
    crate::screen_sound::attached(timeout_ms)
}

/// Takes the mix down. The session also ends by itself once the plugin
/// stops recording.
pub fn screen_sound_stop() {
    crate::screen_sound::stop();
}
