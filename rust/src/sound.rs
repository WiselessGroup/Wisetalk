//! The platform side of `api::sound`, kept out of `api` so the bindings
//! generator doesn't publish it.

pub(crate) use imp::play;

#[cfg(not(target_os = "linux"))]
mod imp {
    /// Windows and macOS play through audioplayers for now (WLK-8).
    pub fn play(_pcm: &[u8], _rate: u32, _device: Option<&str>) -> bool {
        false
    }
}

/// PulseAudio's simple API, which PipeWire speaks too (pipewire-pulse),
/// and which libwebrtc's own audio device module plays the call through:
/// the output ids the app gets from flutter_webrtc are sink names. Loaded
/// at run time, so neither building nor running needs PulseAudio's
/// development files, and a system without it plays as before.
#[cfg(target_os = "linux")]
mod imp {
    use std::ffi::{CStr, CString, c_char, c_int, c_void};
    use std::sync::OnceLock;

    const PLAYBACK: c_int = 1;
    const S16LE: c_int = 3;

    #[repr(C)]
    struct SampleSpec {
        format: c_int,
        rate: u32,
        channels: u8,
    }

    type New = unsafe extern "C" fn(
        server: *const c_char,
        name: *const c_char,
        direction: c_int,
        device: *const c_char,
        stream_name: *const c_char,
        spec: *const SampleSpec,
        map: *const c_void,
        attr: *const c_void,
        error: *mut c_int,
    ) -> *mut c_void;
    type Write = unsafe extern "C" fn(
        s: *mut c_void,
        data: *const c_void,
        bytes: usize,
        error: *mut c_int,
    ) -> c_int;
    type Drain = unsafe extern "C" fn(s: *mut c_void, error: *mut c_int) -> c_int;
    type Free = unsafe extern "C" fn(s: *mut c_void);

    struct Pulse {
        new: New,
        write: Write,
        drain: Drain,
        free: Free,
    }

    fn pulse() -> Option<&'static Pulse> {
        static PULSE: OnceLock<Option<Pulse>> = OnceLock::new();
        PULSE
            .get_or_init(|| {
                // SAFETY: dlopen and dlsym with valid C strings; the library
                // stays loaded for the life of the process, so the
                // function pointers stay valid.
                unsafe {
                    let library = libc::dlopen(
                        c"libpulse-simple.so.0".as_ptr(),
                        libc::RTLD_NOW | libc::RTLD_LOCAL,
                    );
                    if library.is_null() {
                        return None;
                    }
                    let symbol = |name: &CStr| {
                        let found = libc::dlsym(library, name.as_ptr());
                        (!found.is_null()).then_some(found)
                    };
                    Some(Pulse {
                        new: std::mem::transmute::<*mut c_void, New>(symbol(
                            c"pa_simple_new",
                        )?),
                        write: std::mem::transmute::<*mut c_void, Write>(symbol(
                            c"pa_simple_write",
                        )?),
                        drain: std::mem::transmute::<*mut c_void, Drain>(symbol(
                            c"pa_simple_drain",
                        )?),
                        free: std::mem::transmute::<*mut c_void, Free>(symbol(
                            c"pa_simple_free",
                        )?),
                    })
                }
            })
            .as_ref()
    }

    pub fn play(pcm: &[u8], rate: u32, device: Option<&str>) -> bool {
        let Some(pulse) = pulse() else {
            return false;
        };
        let device = device.and_then(|d| CString::new(d).ok());
        // The chosen output, or the default when it went away.
        let stream = open(pulse, rate, device.as_deref())
            .or_else(|| device.as_ref().and_then(|_| open(pulse, rate, None)));
        let Some(stream) = stream else {
            return false;
        };
        let mut error = 0;
        // SAFETY: `stream` came from pa_simple_new and is freed only here;
        // `pcm` outlives the calls.
        unsafe {
            let written = (pulse.write)(
                stream,
                pcm.as_ptr().cast(),
                pcm.len(),
                &mut error,
            ) == 0
                && (pulse.drain)(stream, &mut error) == 0;
            (pulse.free)(stream);
            written
        }
    }

    fn open(pulse: &Pulse, rate: u32, device: Option<&CStr>) -> Option<*mut c_void> {
        let spec = SampleSpec {
            format: S16LE,
            rate,
            channels: 1,
        };
        let mut error = 0;
        // SAFETY: every pointer is a valid C string or struct for the call,
        // or null where the API allows it.
        let stream = unsafe {
            (pulse.new)(
                std::ptr::null(),
                c"Wisetalk".as_ptr(),
                PLAYBACK,
                device.map_or(std::ptr::null(), CStr::as_ptr),
                c"Sound cue".as_ptr(),
                &spec,
                std::ptr::null(),
                std::ptr::null(),
                &mut error,
            )
        };
        (!stream.is_null()).then_some(stream)
    }
}
