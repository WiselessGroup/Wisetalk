//! The platform side of `api::screen_sound`: the shared screen's sound on
//! Linux without the call in it.
//!
//! flutter_webrtc records a screen share's sound from the monitor of the
//! default output, where the voices of the call play too, so everyone would
//! hear themselves. Windows leaves our own process out in the plugin
//! (WASAPI process loopback), Android in ScreenSound.kt. Here a session
//! does it from the outside, through libpulse, which PipeWire speaks as
//! well (pipewire-pulse):
//!
//! 1. it loads a null sink of its own, `wisetalk_screen_sound`;
//! 2. it records every playback stream of every other process from its
//!    sink's monitor (`pa_stream_set_monitor_stream`), mixes them and plays
//!    the mix into that sink. What the person hears doesn't change;
//! 3. when the plugin opens its recording ("System audio loopback"), it
//!    moves it to the null sink's monitor, so the plugin records the mix.
//!
//! The session ends when the plugin's recording goes away, or when the app
//! stops it, and unloads its sink. libpulse is loaded at run time, as for
//! the owl's cues (`sound.rs`): without it there is no sound to share.

pub(crate) use imp::{attached, start, stop};

#[cfg(not(target_os = "linux"))]
mod imp {
    pub fn start() -> bool {
        false
    }

    pub fn attached(_timeout_ms: u32) -> bool {
        false
    }

    pub fn stop() {}
}

#[cfg(target_os = "linux")]
mod imp {
    use std::collections::HashMap;
    use std::collections::VecDeque;
    use std::ffi::{CStr, c_char, c_int, c_void};
    use std::sync::atomic::{AtomicBool, AtomicPtr, Ordering};
    use std::sync::{Arc, Condvar, Mutex, OnceLock};
    use std::thread::JoinHandle;
    use std::time::Duration;

    const SINK_NAME: &CStr = c"wisetalk_screen_sound";
    const MONITOR_NAME: &CStr = c"wisetalk_screen_sound.monitor";
    const SINK_ARGUMENTS: &CStr = c"sink_name=wisetalk_screen_sound rate=48000 channels=2 \
        sink_properties=device.description=Wisetalk\\ screen\\ sound";
    /// What flutter_webrtc calls its recording (linux/pulse_loopback_capturer.cc).
    const PLUGIN_STREAM: &[u8] = b"System audio loopback";

    const RATE: u32 = 48_000;
    const CHANNELS: usize = 2;
    const FRAME_BYTES: usize = CHANNELS * size_of::<f32>();
    /// Samples (both channels) in `ms` milliseconds.
    const fn samples(ms: usize) -> usize {
        RATE as usize / 1000 * ms * CHANNELS
    }
    /// A stream joins the mix once this much has come in, so that one late
    /// packet doesn't click.
    const PRIME: usize = samples(20);
    /// More than this behind and the oldest goes: the sound keeps up with
    /// the picture.
    const BACKLOG: usize = samples(200);

    // pulse/def.h, pulse/sample.h, pulse/subscribe.h.
    const CONTEXT_READY: c_int = 4;
    const CONTEXT_FAILED: c_int = 5;
    const CONTEXT_TERMINATED: c_int = 6;
    const OPERATION_RUNNING: c_int = 0;
    const FLOAT32LE: c_int = 5;
    const STREAM_ADJUST_LATENCY: c_int = 0x2000;
    const SUBSCRIBE_SINK_INPUT: c_int = 0x0004;
    const SUBSCRIBE_SOURCE_OUTPUT: c_int = 0x0008;
    const FACILITY_MASK: c_int = 0x0F;
    const TYPE_MASK: c_int = 0x30;
    const FACILITY_SINK_INPUT: c_int = 2;
    const FACILITY_SOURCE_OUTPUT: c_int = 3;
    const EVENT_REMOVE: c_int = 0x20;
    const INVALID_INDEX: u32 = u32::MAX;

    #[repr(C)]
    #[allow(dead_code, reason = "mirrors the C layout")]
    struct SampleSpec {
        format: c_int,
        rate: u32,
        channels: u8,
    }

    #[repr(C)]
    #[allow(dead_code, reason = "mirrors the C layout")]
    struct ChannelMap {
        channels: u8,
        map: [c_int; 32],
    }

    #[repr(C)]
    #[allow(dead_code, reason = "mirrors the C layout")]
    struct CVolume {
        channels: u8,
        values: [u32; 32],
    }

    #[repr(C)]
    #[allow(dead_code, reason = "mirrors the C layout")]
    struct BufferAttr {
        maxlength: u32,
        tlength: u32,
        prebuf: u32,
        minreq: u32,
        fragsize: u32,
    }

    /// The start of pa_sink_input_info (pulse/introspect.h), up to the
    /// proplist.
    #[repr(C)]
    #[allow(dead_code, reason = "mirrors the C layout")]
    struct SinkInputInfo {
        index: u32,
        name: *const c_char,
        owner_module: u32,
        client: u32,
        sink: u32,
        sample_spec: SampleSpec,
        channel_map: ChannelMap,
        volume: CVolume,
        buffer_usec: u64,
        sink_usec: u64,
        resample_method: *const c_char,
        driver: *const c_char,
        mute: c_int,
        proplist: *mut c_void,
    }

    /// The start of pa_source_output_info, up to the proplist.
    #[repr(C)]
    #[allow(dead_code, reason = "mirrors the C layout")]
    struct SourceOutputInfo {
        index: u32,
        name: *const c_char,
        owner_module: u32,
        client: u32,
        source: u32,
        sample_spec: SampleSpec,
        channel_map: ChannelMap,
        buffer_usec: u64,
        source_usec: u64,
        resample_method: *const c_char,
        driver: *const c_char,
        proplist: *mut c_void,
    }

    /// The start of pa_sink_info, up to the monitor's name.
    #[repr(C)]
    #[allow(dead_code, reason = "mirrors the C layout")]
    struct SinkInfo {
        name: *const c_char,
        index: u32,
        description: *const c_char,
        sample_spec: SampleSpec,
        channel_map: ChannelMap,
        owner_module: u32,
        volume: CVolume,
        mute: c_int,
        monitor_source: u32,
        monitor_source_name: *const c_char,
    }

    /// The start of pa_module_info.
    #[repr(C)]
    #[allow(dead_code, reason = "mirrors the C layout")]
    struct ModuleInfo {
        index: u32,
        name: *const c_char,
        argument: *const c_char,
    }

    type P = *mut c_void;
    type InfoCallback<T> = unsafe extern "C" fn(P, *const T, c_int, P);
    type IndexCallback = unsafe extern "C" fn(P, u32, P);
    type SuccessCallback = unsafe extern "C" fn(P, c_int, P);
    type SubscribeCallback = unsafe extern "C" fn(P, c_int, u32, P);
    type RequestCallback = unsafe extern "C" fn(P, usize, P);

    /// The libpulse functions a session uses.
    struct Pulse {
        mainloop_new: unsafe extern "C" fn() -> P,
        mainloop_get_api: unsafe extern "C" fn(P) -> P,
        mainloop_iterate: unsafe extern "C" fn(P, c_int, *mut c_int) -> c_int,
        mainloop_wakeup: unsafe extern "C" fn(P),
        mainloop_free: unsafe extern "C" fn(P),
        context_new: unsafe extern "C" fn(P, *const c_char) -> P,
        context_connect: unsafe extern "C" fn(P, *const c_char, c_int, *const c_void) -> c_int,
        context_get_state: unsafe extern "C" fn(P) -> c_int,
        context_disconnect: unsafe extern "C" fn(P),
        context_unref: unsafe extern "C" fn(P),
        context_load_module:
            unsafe extern "C" fn(P, *const c_char, *const c_char, IndexCallback, P) -> P,
        context_unload_module: unsafe extern "C" fn(P, u32, SuccessCallback, P) -> P,
        context_get_module_info_list: unsafe extern "C" fn(P, InfoCallback<ModuleInfo>, P) -> P,
        context_get_sink_info_by_index:
            unsafe extern "C" fn(P, u32, InfoCallback<SinkInfo>, P) -> P,
        context_get_sink_input_info:
            unsafe extern "C" fn(P, u32, InfoCallback<SinkInputInfo>, P) -> P,
        context_get_sink_input_info_list:
            unsafe extern "C" fn(P, InfoCallback<SinkInputInfo>, P) -> P,
        context_get_source_output_info:
            unsafe extern "C" fn(P, u32, InfoCallback<SourceOutputInfo>, P) -> P,
        context_get_source_output_info_list:
            unsafe extern "C" fn(P, InfoCallback<SourceOutputInfo>, P) -> P,
        context_move_source_output_by_name:
            unsafe extern "C" fn(P, u32, *const c_char, SuccessCallback, P) -> P,
        context_set_subscribe_callback: unsafe extern "C" fn(P, SubscribeCallback, P),
        context_subscribe: unsafe extern "C" fn(P, c_int, Option<SuccessCallback>, P) -> P,
        operation_get_state: unsafe extern "C" fn(P) -> c_int,
        operation_unref: unsafe extern "C" fn(P),
        proplist_gets: unsafe extern "C" fn(P, *const c_char) -> *const c_char,
        stream_new: unsafe extern "C" fn(P, *const c_char, *const SampleSpec, *const c_void) -> P,
        stream_set_monitor_stream: unsafe extern "C" fn(P, u32) -> c_int,
        stream_set_read_callback: unsafe extern "C" fn(P, Option<RequestCallback>, P),
        stream_set_write_callback: unsafe extern "C" fn(P, Option<RequestCallback>, P),
        stream_connect_record:
            unsafe extern "C" fn(P, *const c_char, *const BufferAttr, c_int) -> c_int,
        stream_connect_playback: unsafe extern "C" fn(
            P,
            *const c_char,
            *const BufferAttr,
            c_int,
            *const c_void,
            P,
        ) -> c_int,
        stream_peek: unsafe extern "C" fn(P, *mut *const c_void, *mut usize) -> c_int,
        stream_drop: unsafe extern "C" fn(P) -> c_int,
        stream_write:
            unsafe extern "C" fn(P, *const c_void, usize, *const c_void, i64, c_int) -> c_int,
        stream_disconnect: unsafe extern "C" fn(P) -> c_int,
        stream_unref: unsafe extern "C" fn(P),
    }

    /// The address of `name` in `library`, as a function of type `F`.
    ///
    /// # Safety
    ///
    /// `F` must be the function's real type.
    unsafe fn symbol<F: Copy>(library: P, name: &CStr) -> Option<F> {
        // SAFETY: dlsym with a live handle and a C string.
        let found = unsafe { libc::dlsym(library, name.as_ptr()) };
        // SAFETY: a function pointer is as big as a data pointer here, and
        // the caller vouches for the type.
        (!found.is_null()).then(|| unsafe { std::mem::transmute_copy::<P, F>(&found) })
    }

    fn pulse() -> Option<&'static Pulse> {
        static PULSE: OnceLock<Option<Pulse>> = OnceLock::new();
        PULSE
            .get_or_init(|| {
                // SAFETY: dlopen with a C string; the library stays loaded
                // for the life of the process.
                let l = unsafe {
                    libc::dlopen(c"libpulse.so.0".as_ptr(), libc::RTLD_NOW | libc::RTLD_LOCAL)
                };
                if l.is_null() {
                    return None;
                }
                // SAFETY: each type is the C function's, from pulse/*.h.
                unsafe {
                    Some(Pulse {
                        mainloop_new: symbol(l, c"pa_mainloop_new")?,
                        mainloop_get_api: symbol(l, c"pa_mainloop_get_api")?,
                        mainloop_iterate: symbol(l, c"pa_mainloop_iterate")?,
                        mainloop_wakeup: symbol(l, c"pa_mainloop_wakeup")?,
                        mainloop_free: symbol(l, c"pa_mainloop_free")?,
                        context_new: symbol(l, c"pa_context_new")?,
                        context_connect: symbol(l, c"pa_context_connect")?,
                        context_get_state: symbol(l, c"pa_context_get_state")?,
                        context_disconnect: symbol(l, c"pa_context_disconnect")?,
                        context_unref: symbol(l, c"pa_context_unref")?,
                        context_load_module: symbol(l, c"pa_context_load_module")?,
                        context_unload_module: symbol(l, c"pa_context_unload_module")?,
                        context_get_module_info_list: symbol(
                            l,
                            c"pa_context_get_module_info_list",
                        )?,
                        context_get_sink_info_by_index: symbol(
                            l,
                            c"pa_context_get_sink_info_by_index",
                        )?,
                        context_get_sink_input_info: symbol(l, c"pa_context_get_sink_input_info")?,
                        context_get_sink_input_info_list: symbol(
                            l,
                            c"pa_context_get_sink_input_info_list",
                        )?,
                        context_get_source_output_info: symbol(
                            l,
                            c"pa_context_get_source_output_info",
                        )?,
                        context_get_source_output_info_list: symbol(
                            l,
                            c"pa_context_get_source_output_info_list",
                        )?,
                        context_move_source_output_by_name: symbol(
                            l,
                            c"pa_context_move_source_output_by_name",
                        )?,
                        context_set_subscribe_callback: symbol(
                            l,
                            c"pa_context_set_subscribe_callback",
                        )?,
                        context_subscribe: symbol(l, c"pa_context_subscribe")?,
                        operation_get_state: symbol(l, c"pa_operation_get_state")?,
                        operation_unref: symbol(l, c"pa_operation_unref")?,
                        proplist_gets: symbol(l, c"pa_proplist_gets")?,
                        stream_new: symbol(l, c"pa_stream_new")?,
                        stream_set_monitor_stream: symbol(l, c"pa_stream_set_monitor_stream")?,
                        stream_set_read_callback: symbol(l, c"pa_stream_set_read_callback")?,
                        stream_set_write_callback: symbol(l, c"pa_stream_set_write_callback")?,
                        stream_connect_record: symbol(l, c"pa_stream_connect_record")?,
                        stream_connect_playback: symbol(l, c"pa_stream_connect_playback")?,
                        stream_peek: symbol(l, c"pa_stream_peek")?,
                        stream_drop: symbol(l, c"pa_stream_drop")?,
                        stream_write: symbol(l, c"pa_stream_write")?,
                        stream_disconnect: symbol(l, c"pa_stream_disconnect")?,
                        stream_unref: symbol(l, c"pa_stream_unref")?,
                    })
                }
            })
            .as_ref()
    }

    /// What the app and the session's thread share.
    #[derive(Default)]
    struct Shared {
        quit: AtomicBool,
        mainloop: AtomicPtr<c_void>,
        state: Mutex<State>,
        changed: Condvar,
    }

    #[derive(Default)]
    struct State {
        /// `Some` once the session is set up or has failed to.
        ready: Option<bool>,
        /// The plugin's recording now records the mix.
        attached: bool,
        ended: bool,
    }

    impl Shared {
        fn update(&self, change: impl FnOnce(&mut State)) {
            change(&mut self.state.lock().unwrap());
            self.changed.notify_all();
        }

        /// Waits until `done` holds, or `timeout` passes; whether it held.
        fn wait(&self, timeout: Duration, done: impl Fn(&State) -> bool) -> bool {
            let state = self.state.lock().unwrap();
            let (state, _) = self
                .changed
                .wait_timeout_while(state, timeout, |s| !done(s))
                .unwrap();
            done(&state)
        }
    }

    struct Session {
        shared: Arc<Shared>,
        thread: JoinHandle<()>,
    }

    static SESSION: Mutex<Option<Session>> = Mutex::new(None);

    pub fn start() -> bool {
        stop();
        if pulse().is_none() {
            return false;
        }
        let shared = Arc::new(Shared::default());
        let thread = {
            let shared = shared.clone();
            std::thread::Builder::new()
                .name("screen sound".into())
                .spawn(move || run(&shared))
        };
        let Ok(thread) = thread else {
            return false;
        };
        let ready = shared.wait(Duration::from_secs(3), |s| s.ready.is_some())
            && shared.state.lock().unwrap().ready == Some(true);
        *SESSION.lock().unwrap() = Some(Session { shared, thread });
        if !ready {
            stop();
        }
        ready
    }

    pub fn attached(timeout_ms: u32) -> bool {
        let Some(shared) = SESSION.lock().unwrap().as_ref().map(|s| s.shared.clone()) else {
            return false;
        };
        shared.wait(Duration::from_millis(timeout_ms.into()), |s| {
            s.attached || s.ended
        }) && shared.state.lock().unwrap().attached
    }

    pub fn stop() {
        let Some(session) = SESSION.lock().unwrap().take() else {
            return;
        };
        session.shared.quit.store(true, Ordering::SeqCst);
        let mainloop = session.shared.mainloop.load(Ordering::SeqCst);
        if !mainloop.is_null() {
            // SAFETY: the thread frees the main loop only after it has
            // seen `quit`, which is set above, and clears the pointer
            // first; pa_mainloop_wakeup may be called from any thread.
            unsafe { (pulse().unwrap().mainloop_wakeup)(mainloop) };
        }
        let _ = session.thread.join();
    }

    /// One stream being recorded into the mix.
    struct Input {
        stream: P,
        sink: u32,
        buffer: VecDeque<f32>,
        primed: bool,
    }

    /// Everything the callbacks reach, owned by the session's thread.
    struct Mixer {
        pulse: &'static Pulse,
        shared: Arc<Shared>,
        own_pid: String,
        inputs: HashMap<u32, Box<Input>>,
        /// The plugin's recording, once moved here.
        plugin: Option<u32>,
        mix: Vec<f32>,
    }

    /// A sink input waiting for its sink's monitor.
    struct Pending {
        mixer: *mut Mixer,
        sink_input: u32,
    }

    fn run(shared: &Arc<Shared>) {
        let pulse = pulse().unwrap();
        // SAFETY: the libpulse sequence on a main loop private to this
        // thread; every callback runs inside mainloop_iterate here, while
        // `mixer` lives.
        unsafe {
            let mainloop = (pulse.mainloop_new)();
            if mainloop.is_null() {
                shared.update(|s| s.ready = Some(false));
                return;
            }
            shared.mainloop.store(mainloop, Ordering::SeqCst);
            let context =
                (pulse.context_new)((pulse.mainloop_get_api)(mainloop), c"Wisetalk".as_ptr());
            let mut mixer = Box::new(Mixer {
                pulse,
                shared: shared.clone(),
                own_pid: std::process::id().to_string(),
                inputs: HashMap::new(),
                plugin: None,
                mix: Vec::new(),
            });
            let mut module = INVALID_INDEX;
            let mut output: P = std::ptr::null_mut();
            let ok = !context.is_null() && {
                let m: *mut Mixer = &raw mut *mixer;
                set_up(pulse, mainloop, context, m, &mut module, &mut output)
            };
            shared.update(|s| s.ready = Some(ok));
            if ok {
                // Blocks until libpulse has something, or stop() wakes it.
                while !shared.quit.load(Ordering::SeqCst) && !shared.state.lock().unwrap().ended {
                    if (pulse.mainloop_iterate)(mainloop, 1, std::ptr::null_mut()) < 0 {
                        break;
                    }
                }
            }
            // Down in reverse: the streams, then the sink. The plugin's
            // recording, if still there, goes back to the default output's
            // monitor; the app has unpublished the sound by then.
            for (_, input) in mixer.inputs.drain() {
                close(pulse, input.stream);
            }
            if !output.is_null() {
                (pulse.stream_set_write_callback)(output, None, std::ptr::null_mut());
                close(pulse, output);
            }
            if module != INVALID_INDEX {
                let op =
                    (pulse.context_unload_module)(context, module, done_ok, std::ptr::null_mut());
                wait(pulse, mainloop, op);
            }
            if !context.is_null() {
                (pulse.context_disconnect)(context);
                (pulse.context_unref)(context);
            }
            shared
                .mainloop
                .store(std::ptr::null_mut(), Ordering::SeqCst);
            (pulse.mainloop_free)(mainloop);
        }
        shared.update(|s| s.ended = true);
    }

    /// Connects, loads the sink, starts the mix and listens for streams.
    ///
    /// # Safety
    ///
    /// Live `mainloop` and `context`; `mixer` outlives the main loop.
    unsafe fn set_up(
        pulse: &'static Pulse,
        mainloop: P,
        context: P,
        mixer: *mut Mixer,
        module: &mut u32,
        output: &mut P,
    ) -> bool {
        unsafe {
            if (pulse.context_connect)(context, std::ptr::null(), 0, std::ptr::null()) < 0 {
                return false;
            }
            loop {
                match (pulse.context_get_state)(context) {
                    CONTEXT_READY => break,
                    CONTEXT_FAILED | CONTEXT_TERMINATED => return false,
                    _ => {
                        if (pulse.mainloop_iterate)(mainloop, 1, std::ptr::null_mut()) < 0 {
                            return false;
                        }
                    }
                }
            }

            // A sink left over by an app that didn't get to unload it.
            let mut leftovers: Vec<u32> = Vec::new();
            let op = (pulse.context_get_module_info_list)(
                context,
                leftover,
                (&raw mut leftovers).cast(),
            );
            wait(pulse, mainloop, op);
            for index in leftovers {
                let op =
                    (pulse.context_unload_module)(context, index, done_ok, std::ptr::null_mut());
                wait(pulse, mainloop, op);
            }

            let op = (pulse.context_load_module)(
                context,
                c"module-null-sink".as_ptr(),
                SINK_ARGUMENTS.as_ptr(),
                loaded,
                (module as *mut u32).cast(),
            );
            wait(pulse, mainloop, op);
            if *module == INVALID_INDEX {
                return false;
            }

            let spec = SampleSpec {
                format: FLOAT32LE,
                rate: RATE,
                channels: CHANNELS as u8,
            };
            *output =
                (pulse.stream_new)(context, c"Screen sound".as_ptr(), &spec, std::ptr::null());
            if output.is_null() {
                return false;
            }
            let attr = BufferAttr {
                maxlength: u32::MAX,
                tlength: (samples(30) * size_of::<f32>()) as u32,
                prebuf: u32::MAX,
                minreq: (samples(10) * size_of::<f32>()) as u32,
                fragsize: u32::MAX,
            };
            (pulse.stream_set_write_callback)(*output, Some(write_mix), mixer.cast());
            if (pulse.stream_connect_playback)(
                *output,
                SINK_NAME.as_ptr(),
                &attr,
                STREAM_ADJUST_LATENCY,
                std::ptr::null(),
                std::ptr::null_mut(),
            ) < 0
            {
                return false;
            }

            (pulse.context_set_subscribe_callback)(context, changed, mixer.cast());
            let op = (pulse.context_subscribe)(
                context,
                SUBSCRIBE_SINK_INPUT | SUBSCRIBE_SOURCE_OUTPUT,
                None,
                std::ptr::null_mut(),
            );
            wait(pulse, mainloop, op);
            let op = (pulse.context_get_sink_input_info_list)(context, sink_input, mixer.cast());
            wait(pulse, mainloop, op);
            let op =
                (pulse.context_get_source_output_info_list)(context, source_output, mixer.cast());
            wait(pulse, mainloop, op);
            true
        }
    }

    /// Runs the main loop until `op` is done, and lets it go.
    ///
    /// # Safety
    ///
    /// A live main loop; `op` from libpulse or null.
    unsafe fn wait(pulse: &Pulse, mainloop: P, op: P) {
        if op.is_null() {
            return;
        }
        unsafe {
            while (pulse.operation_get_state)(op) == OPERATION_RUNNING {
                if (pulse.mainloop_iterate)(mainloop, 1, std::ptr::null_mut()) < 0 {
                    break;
                }
            }
            (pulse.operation_unref)(op);
        }
    }

    /// Lets go of an operation whose callback does the rest.
    ///
    /// # Safety
    ///
    /// `op` from libpulse or null.
    unsafe fn forget(pulse: &Pulse, op: P) {
        if !op.is_null() {
            unsafe { (pulse.operation_unref)(op) };
        }
    }

    /// # Safety
    ///
    /// A stream from pa_stream_new.
    unsafe fn close(pulse: &Pulse, stream: P) {
        unsafe {
            (pulse.stream_set_read_callback)(stream, None, std::ptr::null_mut());
            (pulse.stream_disconnect)(stream);
            (pulse.stream_unref)(stream);
        }
    }

    /// The value of `key` in a proplist.
    ///
    /// # Safety
    ///
    /// A live proplist or null.
    unsafe fn property<'a>(pulse: &Pulse, proplist: P, key: &CStr) -> Option<&'a [u8]> {
        if proplist.is_null() {
            return None;
        }
        let value = unsafe { (pulse.proplist_gets)(proplist, key.as_ptr()) };
        (!value.is_null()).then(|| unsafe { CStr::from_ptr(value) }.to_bytes())
    }

    unsafe extern "C" fn done_ok(_: P, _: c_int, _: P) {}

    unsafe extern "C" fn loaded(_: P, index: u32, data: P) {
        // SAFETY: `data` is the u32 set_up waits on.
        unsafe { *data.cast::<u32>() = index };
    }

    unsafe extern "C" fn leftover(_: P, info: *const ModuleInfo, eol: c_int, data: P) {
        if eol != 0 || info.is_null() {
            return;
        }
        // SAFETY: a live pa_module_info; `data` is set_up's Vec.
        unsafe {
            let info = &*info;
            if info.argument.is_null() {
                return;
            }
            let argument = CStr::from_ptr(info.argument).to_bytes();
            let wanted = [b"sink_name=".as_slice(), SINK_NAME.to_bytes()].concat();
            if argument
                .windows(wanted.len())
                .any(|w| w == wanted.as_slice())
            {
                data.cast::<Vec<u32>>().as_mut().unwrap().push(info.index);
            }
        }
    }

    unsafe extern "C" fn changed(context: P, event: c_int, index: u32, data: P) {
        // SAFETY: `data` is the session's Mixer, alive while the main loop
        // runs.
        unsafe {
            let mixer = &mut *data.cast::<Mixer>();
            let pulse = mixer.pulse;
            let removed = event & TYPE_MASK == EVENT_REMOVE;
            match event & FACILITY_MASK {
                FACILITY_SINK_INPUT if removed => {
                    if let Some(input) = mixer.inputs.remove(&index) {
                        close(pulse, input.stream);
                    }
                }
                FACILITY_SINK_INPUT => {
                    forget(
                        pulse,
                        (pulse.context_get_sink_input_info)(context, index, sink_input, data),
                    );
                }
                FACILITY_SOURCE_OUTPUT if removed => {
                    // The plugin stopped recording: the share is over.
                    if mixer.plugin == Some(index) {
                        mixer.shared.update(|s| s.ended = true);
                    }
                }
                FACILITY_SOURCE_OUTPUT => {
                    forget(
                        pulse,
                        (pulse.context_get_source_output_info)(context, index, source_output, data),
                    );
                }
                _ => {}
            }
        }
    }

    /// A playback stream came or changed: anyone's but ours goes into the
    /// mix, recorded from the monitor of the sink it plays on.
    unsafe extern "C" fn sink_input(context: P, info: *const SinkInputInfo, eol: c_int, data: P) {
        if eol != 0 || info.is_null() {
            return;
        }
        // SAFETY: a live pa_sink_input_info; `data` is the Mixer.
        unsafe {
            let info = &*info;
            let mixer = &mut *data.cast::<Mixer>();
            let pulse = mixer.pulse;
            let pid = property(pulse, info.proplist, c"application.process.id");
            // Not playing anywhere yet: a change follows once it does.
            if pid == Some(mixer.own_pid.as_bytes()) || info.sink == INVALID_INDEX {
                return;
            }
            if mixer
                .inputs
                .get(&info.index)
                .is_some_and(|i| i.sink == info.sink)
            {
                return;
            }
            // New, or moved to another sink: record it again from there.
            if let Some(input) = mixer.inputs.remove(&info.index) {
                close(pulse, input.stream);
            }
            let pending = Box::into_raw(Box::new(Pending {
                mixer: data.cast(),
                sink_input: info.index,
            }));
            let op =
                (pulse.context_get_sink_info_by_index)(context, info.sink, record, pending.cast());
            if op.is_null() {
                drop(Box::from_raw(pending));
            } else {
                forget(pulse, op);
            }
        }
    }

    /// The sink's monitor for a pending stream: start recording it.
    unsafe extern "C" fn record(context: P, info: *const SinkInfo, eol: c_int, data: P) {
        // SAFETY: `data` is the Pending boxed in sink_input; the list ends
        // with eol set, which frees it. A live pa_sink_info otherwise.
        unsafe {
            if eol != 0 {
                drop(Box::from_raw(data.cast::<Pending>()));
                return;
            }
            if info.is_null() {
                return;
            }
            let info = &*info;
            let pending = &*data.cast::<Pending>();
            let mixer = &mut *pending.mixer;
            let pulse = mixer.pulse;
            if info.monitor_source_name.is_null() || mixer.inputs.contains_key(&pending.sink_input)
            {
                return;
            }
            // Our own sink plays nothing but our mix.
            if info.name.is_null() || CStr::from_ptr(info.name) == SINK_NAME {
                return;
            }
            let spec = SampleSpec {
                format: FLOAT32LE,
                rate: RATE,
                channels: CHANNELS as u8,
            };
            let stream = (pulse.stream_new)(
                context,
                c"Screen sound source".as_ptr(),
                &spec,
                std::ptr::null(),
            );
            if stream.is_null() {
                return;
            }
            let mut input = Box::new(Input {
                stream,
                sink: info.index,
                buffer: VecDeque::with_capacity(BACKLOG),
                primed: false,
            });
            let attr = BufferAttr {
                maxlength: u32::MAX,
                tlength: u32::MAX,
                prebuf: u32::MAX,
                minreq: u32::MAX,
                fragsize: (samples(10) * size_of::<f32>()) as u32,
            };
            (pulse.stream_set_read_callback)(stream, Some(read_input), (&raw mut *input).cast());
            if (pulse.stream_set_monitor_stream)(stream, pending.sink_input) < 0
                || (pulse.stream_connect_record)(
                    stream,
                    info.monitor_source_name,
                    &attr,
                    STREAM_ADJUST_LATENCY,
                ) < 0
            {
                close(pulse, stream);
                return;
            }
            mixer.inputs.insert(pending.sink_input, input);
        }
    }

    unsafe extern "C" fn read_input(stream: P, _: usize, data: P) {
        // SAFETY: `data` is the boxed Input, whose read callback is cleared
        // before it goes; peek and drop on its own stream.
        unsafe {
            let input = &mut *data.cast::<Input>();
            let pulse = pulse().unwrap();
            loop {
                let mut bytes: *const c_void = std::ptr::null();
                let mut length = 0usize;
                if (pulse.stream_peek)(stream, &mut bytes, &mut length) < 0 || length == 0 {
                    return;
                }
                // Null with a length is a hole: nothing to keep.
                if !bytes.is_null() {
                    let count = length / FRAME_BYTES * CHANNELS;
                    let sound = std::slice::from_raw_parts(bytes.cast::<f32>(), count);
                    input.buffer.extend(sound);
                    if input.buffer.len() > BACKLOG {
                        let extra = input.buffer.len() - PRIME;
                        input.buffer.drain(..extra);
                    }
                }
                (pulse.stream_drop)(stream);
            }
        }
    }

    /// The null sink wants more: everything recorded so far, summed.
    unsafe extern "C" fn write_mix(stream: P, length: usize, data: P) {
        // SAFETY: `data` is the Mixer; the write callback is cleared before
        // it goes.
        unsafe {
            let mixer = &mut *data.cast::<Mixer>();
            let count = length / FRAME_BYTES * CHANNELS;
            mixer.mix.clear();
            mixer.mix.resize(count, 0.0);
            for input in mixer.inputs.values_mut() {
                if !input.primed {
                    input.primed = input.buffer.len() >= PRIME;
                    if !input.primed {
                        continue;
                    }
                }
                let take = count.min(input.buffer.len());
                for (out, sample) in mixer.mix.iter_mut().zip(input.buffer.drain(..take)) {
                    *out += sample;
                }
                // Ran dry: wait for a little again before playing it.
                if take < count {
                    input.primed = false;
                }
            }
            for sample in &mut mixer.mix {
                *sample = sample.clamp(-1.0, 1.0);
            }
            (mixer.pulse.stream_write)(
                stream,
                mixer.mix.as_ptr().cast(),
                count * size_of::<f32>(),
                std::ptr::null(),
                0,
                0,
            );
        }
    }

    /// A recording came: the plugin's goes to our sink's monitor.
    unsafe extern "C" fn source_output(
        context: P,
        info: *const SourceOutputInfo,
        eol: c_int,
        data: P,
    ) {
        if eol != 0 || info.is_null() {
            return;
        }
        // SAFETY: a live pa_source_output_info; `data` is the Mixer.
        unsafe {
            let info = &*info;
            let mixer = &mut *data.cast::<Mixer>();
            let pulse = mixer.pulse;
            if mixer.plugin == Some(info.index)
                || property(pulse, info.proplist, c"application.process.id")
                    != Some(mixer.own_pid.as_bytes())
                || property(pulse, info.proplist, c"media.name") != Some(PLUGIN_STREAM)
            {
                return;
            }
            mixer.plugin = Some(info.index);
            forget(
                pulse,
                (pulse.context_move_source_output_by_name)(
                    context,
                    info.index,
                    MONITOR_NAME.as_ptr(),
                    moved,
                    data,
                ),
            );
        }
    }

    unsafe extern "C" fn moved(_: P, success: c_int, data: P) {
        // SAFETY: `data` is the Mixer.
        unsafe {
            let mixer = &mut *data.cast::<Mixer>();
            if success != 0 {
                mixer.shared.update(|s| s.attached = true);
            } else {
                // Recording the default output would put the call in.
                mixer.shared.update(|s| s.ended = true);
            }
        }
    }

    #[cfg(test)]
    mod tests {
        use super::*;
        use std::mem::offset_of;

        /// The layouts above against pulse/introspect.h on 64-bit Linux
        /// (offsetof from a C program built against libpulse 17).
        #[test]
        fn layouts_match_libpulse() {
            assert_eq!(offset_of!(SinkInputInfo, sink), 24);
            assert_eq!(offset_of!(SinkInputInfo, proplist), 344);
            assert_eq!(offset_of!(SourceOutputInfo, proplist), 208);
            assert_eq!(offset_of!(SinkInfo, monitor_source), 308);
            assert_eq!(offset_of!(SinkInfo, monitor_source_name), 312);
            assert_eq!(offset_of!(ModuleInfo, argument), 16);
            assert_eq!(size_of::<BufferAttr>(), 20);
        }

        /// Against the real sound server: records what the plugin would
        /// while Wisetalk plays a tone (must stay out) and another process
        /// plays one (must come in). Plays quietly on the speakers.
        /// `cargo test -- --ignored live_mix --nocapture`
        #[test]
        #[ignore = "needs PulseAudio or PipeWire and pw-play, plays sound"]
        fn live_mix() {
            type New = unsafe extern "C" fn(
                *const c_char,
                *const c_char,
                c_int,
                *const c_char,
                *const c_char,
                *const SampleSpec,
                *const c_void,
                *const c_void,
                *mut c_int,
            ) -> P;
            type Read = unsafe extern "C" fn(P, *mut c_void, usize, *mut c_int) -> c_int;
            let tone = |hz: f32, seconds: f32, gain: f32| -> Vec<i16> {
                (0..(48_000.0 * seconds) as usize)
                    .map(|i| {
                        ((i as f32 * hz * std::f32::consts::TAU / 48_000.0).sin() * gain * 32767.0)
                            as i16
                    })
                    .collect()
            };
            // SAFETY: test-only FFI against pulse/simple.h.
            unsafe {
                let l = libc::dlopen(c"libpulse-simple.so.0".as_ptr(), libc::RTLD_NOW);
                assert!(!l.is_null());
                let new: New = symbol(l, c"pa_simple_new").unwrap();
                let read: Read = symbol(l, c"pa_simple_read").unwrap();

                assert!(start(), "session didn't start");
                let spec = SampleSpec {
                    format: 3,
                    rate: 48_000,
                    channels: 2,
                };
                // As the plugin asks: 10 ms fragments.
                let attr = BufferAttr {
                    maxlength: u32::MAX,
                    tlength: u32::MAX,
                    prebuf: u32::MAX,
                    minreq: u32::MAX,
                    fragsize: 1920,
                };
                let mut error = 0;
                let plugin = new(
                    std::ptr::null(),
                    c"flutter_webrtc".as_ptr(),
                    2,
                    c"@DEFAULT_MONITOR@".as_ptr(),
                    c"System audio loopback".as_ptr(),
                    &spec,
                    std::ptr::null(),
                    (&raw const attr).cast(),
                    &mut error,
                );
                assert!(!plugin.is_null(), "pa_simple_new: {error}");
                assert!(attached(2000), "plugin's recording wasn't moved");
                let loudness = |seconds: f32| -> f32 {
                    let mut buffer = vec![0i16; (48_000.0 * seconds) as usize * 2];
                    let mut error = 0;
                    assert!(
                        read(
                            plugin,
                            buffer.as_mut_ptr().cast(),
                            buffer.len() * 2,
                            &mut error
                        ) >= 0
                    );
                    // The last half: past the start of whatever plays.
                    let tail = &buffer[buffer.len() / 2..];
                    let sum: f64 = tail.iter().map(|&s| (s as f64 / 32768.0).powi(2)).sum();
                    (sum / tail.len() as f64).sqrt() as f32
                };

                // Ours: a tone from this process, on the default output.
                let own = tone(440.0, 1.5, 0.05);
                let player = std::thread::spawn(move || {
                    let bytes: Vec<u8> = own.iter().flat_map(|s| s.to_le_bytes()).collect();
                    crate::sound::play(&bytes, 48_000, None)
                });
                let ours = loudness(1.2);
                assert!(player.join().unwrap(), "couldn't play our own tone");

                // Theirs: pw-play is another process.
                let path = std::env::temp_dir().join("wisetalk-screen-sound-test.wav");
                let pcm: Vec<u8> = tone(660.0, 1.5, 0.05)
                    .iter()
                    .flat_map(|s| s.to_le_bytes())
                    .collect();
                let mut wav = Vec::new();
                wav.extend(b"RIFF");
                wav.extend((36 + pcm.len() as u32).to_le_bytes());
                wav.extend(b"WAVEfmt ");
                wav.extend(16u32.to_le_bytes());
                wav.extend(1u16.to_le_bytes()); // PCM
                wav.extend(1u16.to_le_bytes()); // mono
                wav.extend(48_000u32.to_le_bytes());
                wav.extend(96_000u32.to_le_bytes());
                wav.extend(2u16.to_le_bytes());
                wav.extend(16u16.to_le_bytes());
                wav.extend(b"data");
                wav.extend((pcm.len() as u32).to_le_bytes());
                wav.extend(pcm);
                std::fs::write(&path, wav).unwrap();
                let mut other = std::process::Command::new("pw-play")
                    .arg(&path)
                    .spawn()
                    .expect("pw-play");
                let others = loudness(1.2);
                other.wait().unwrap();
                let _ = std::fs::remove_file(path);

                libc::dlsym(l, c"pa_simple_free".as_ptr())
                    .cast::<c_void>()
                    .is_null()
                    .then(|| panic!("no pa_simple_free"));
                let free: unsafe extern "C" fn(P) = symbol(l, c"pa_simple_free").unwrap();
                free(plugin);
                stop();
                println!("ours {ours:.4}, theirs {others:.4}");
                assert!(ours < 0.002, "our own sound got in: {ours}");
                assert!(others > 0.01, "the other app's sound didn't: {others}");
            }
        }
    }
}
