//! The platform side of `api::sound`, kept out of `api` so the bindings
//! generator doesn't publish it. Each desktop plays through the same
//! system audio API libwebrtc plays the call through, so the output ids
//! flutter_webrtc lists mean the same here: PulseAudio sink names on
//! Linux, WASAPI endpoint ids on Windows, CoreAudio device UIDs on macOS.

pub(crate) use imp::play;

#[cfg(not(any(target_os = "linux", target_os = "windows", target_os = "macos")))]
mod imp {
    /// Phones play their cues their own way (Android in Kotlin, iOS
    /// through audioplayers).
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
                        new: std::mem::transmute::<*mut c_void, New>(symbol(c"pa_simple_new")?),
                        write: std::mem::transmute::<*mut c_void, Write>(symbol(
                            c"pa_simple_write",
                        )?),
                        drain: std::mem::transmute::<*mut c_void, Drain>(symbol(
                            c"pa_simple_drain",
                        )?),
                        free: std::mem::transmute::<*mut c_void, Free>(symbol(c"pa_simple_free")?),
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
            let written = (pulse.write)(stream, pcm.as_ptr().cast(), pcm.len(), &mut error) == 0
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

/// WASAPI in shared mode, which libwebrtc's own audio device module plays
/// the call through too: the output ids the app gets from flutter_webrtc
/// are endpoint ids (`{0.0.0.00000000}.{…}`). Windows converts our mono
/// 48 kHz to whatever the device runs at.
#[cfg(target_os = "windows")]
mod imp {
    use std::thread::sleep;
    use std::time::{Duration, Instant};

    use windows::Win32::Foundation::RPC_E_CHANGED_MODE;
    use windows::Win32::Media::Audio::{
        AUDCLNT_SHAREMODE_SHARED, AUDCLNT_STREAMFLAGS_AUTOCONVERTPCM,
        AUDCLNT_STREAMFLAGS_SRC_DEFAULT_QUALITY, IAudioClient, IAudioRenderClient,
        IMMDeviceEnumerator, MMDeviceEnumerator, WAVE_FORMAT_PCM, WAVEFORMATEX, eConsole, eRender,
    };
    use windows::Win32::System::Com::{
        CLSCTX_ALL, COINIT_MULTITHREADED, CoCreateInstance, CoInitializeEx, CoUninitialize,
    };
    use windows::core::{HSTRING, Result};

    /// The buffer we ask for, in 100 ns units: half a second.
    const BUFFER: i64 = 5_000_000;

    pub fn play(pcm: &[u8], rate: u32, device: Option<&str>) -> bool {
        // SAFETY: joins this thread to COM; undone below when it worked.
        let com = unsafe { CoInitializeEx(None, COINIT_MULTITHREADED) };
        // A thread already in a single-threaded apartment does as well.
        if com.is_err() && com != RPC_E_CHANGED_MODE {
            return false;
        }
        let played = render(pcm, rate, device).is_ok();
        if com.is_ok() {
            // SAFETY: pairs the CoInitializeEx above; `render` has
            // released every COM object it made.
            unsafe { CoUninitialize() };
        }
        played
    }

    fn render(pcm: &[u8], rate: u32, device: Option<&str>) -> Result<()> {
        let format = WAVEFORMATEX {
            wFormatTag: WAVE_FORMAT_PCM as u16,
            nChannels: 1,
            nSamplesPerSec: rate,
            nAvgBytesPerSec: rate * 2,
            nBlockAlign: 2,
            wBitsPerSample: 16,
            cbSize: 0,
        };
        // The chosen output, or the default one when it went away.
        let mut opened = open(device, &format);
        if opened.is_err() && device.is_some() {
            opened = open(None, &format);
        }
        let (client, output) = opened?;

        let frames = pcm.len() / 2;
        let mut written = write(&client, &output, pcm)?;
        // SAFETY: the client is initialized and holds the first samples.
        unsafe { client.Start()? };
        while written < frames {
            sleep(Duration::from_millis(10));
            written += write(&client, &output, &pcm[written * 2..])?;
        }
        // Until what is queued has played, in steps of at most 10 ms, and
        // a little more for the device's own latency.
        let deadline = Instant::now() + Duration::from_secs(1);
        loop {
            // SAFETY: a plain query on the running client.
            let queued = unsafe { client.GetCurrentPadding()? };
            if queued == 0 || Instant::now() > deadline {
                break;
            }
            let left = u64::from(queued) * 1000 / u64::from(rate.max(1));
            sleep(Duration::from_millis(left.clamp(1, 10)));
        }
        sleep(Duration::from_millis(50));
        // SAFETY: stops the client started above.
        unsafe { client.Stop() }
    }

    /// A shared-mode client on `device` (the default output when `None`)
    /// for `format`, and the service that takes its samples.
    fn open(
        device: Option<&str>,
        format: &WAVEFORMATEX,
    ) -> Result<(IAudioClient, IAudioRenderClient)> {
        // SAFETY: COM calls, on a thread in COM, with a valid id string
        // and format; the results own their references.
        unsafe {
            let enumerator: IMMDeviceEnumerator =
                CoCreateInstance(&MMDeviceEnumerator, None, CLSCTX_ALL)?;
            let endpoint = match device {
                Some(id) => enumerator.GetDevice(&HSTRING::from(id))?,
                None => enumerator.GetDefaultAudioEndpoint(eRender, eConsole)?,
            };
            let client: IAudioClient = endpoint.Activate(CLSCTX_ALL, None)?;
            client.Initialize(
                AUDCLNT_SHAREMODE_SHARED,
                AUDCLNT_STREAMFLAGS_AUTOCONVERTPCM | AUDCLNT_STREAMFLAGS_SRC_DEFAULT_QUALITY,
                BUFFER,
                0,
                format,
                None,
            )?;
            let output = client.GetService::<IAudioRenderClient>()?;
            Ok((client, output))
        }
    }

    /// Hands WASAPI as many of `pcm`'s frames as its buffer has room for,
    /// and says how many that was.
    fn write(client: &IAudioClient, output: &IAudioRenderClient, pcm: &[u8]) -> Result<usize> {
        // SAFETY: GetBuffer lends room for `count` frames of two bytes,
        // which are filled from `pcm` and handed back before anything
        // else touches the buffer.
        unsafe {
            let size = client.GetBufferSize()?;
            let room = size.saturating_sub(client.GetCurrentPadding()?);
            let count = room.min((pcm.len() / 2) as u32);
            if count > 0 {
                let buffer = output.GetBuffer(count)?;
                std::ptr::copy_nonoverlapping(pcm.as_ptr(), buffer, count as usize * 2);
                output.ReleaseBuffer(count, 0)?;
            }
            Ok(count as usize)
        }
    }
}

/// CoreAudio's output unit, which libwebrtc's own audio device module
/// plays the call through too: the output ids the app gets from
/// flutter_webrtc are device UIDs. The few functions, constants and
/// structs it takes are declared here, each named after Apple's and with
/// the header it comes from, rather than pulling in a crate per framework.
/// The unit converts our mono 48 kHz to whatever the device runs at.
#[cfg(target_os = "macos")]
mod imp {
    use std::ffi::{CString, c_char, c_void};
    use std::sync::atomic::{AtomicBool, AtomicUsize, Ordering};
    use std::thread::sleep;
    use std::time::{Duration, Instant};

    type OSStatus = i32;
    type AudioObjectID = u32;
    /// AudioComponent and AudioComponentInstance (AudioUnit): opaque.
    type AudioComponent = *mut c_void;
    type AudioUnit = *mut c_void;
    type CFStringRef = *const c_void;

    /// A four-character code as Apple's headers write them ('auou').
    const fn code(name: &[u8; 4]) -> u32 {
        u32::from_be_bytes(*name)
    }

    /// kAudioUnitType_Output, AudioToolbox/AUComponent.h.
    const TYPE_OUTPUT: u32 = code(b"auou");
    /// kAudioUnitSubType_HALOutput, AudioToolbox/AUComponent.h.
    const HAL_OUTPUT: u32 = code(b"ahal");
    /// kAudioUnitSubType_DefaultOutput, AudioToolbox/AUComponent.h.
    const DEFAULT_OUTPUT: u32 = code(b"def ");
    /// kAudioUnitManufacturer_Apple, AudioToolbox/AUComponent.h.
    const APPLE: u32 = code(b"appl");
    /// kAudioUnitProperty_StreamFormat, AudioToolbox/AudioUnitProperties.h.
    const STREAM_FORMAT: u32 = 8;
    /// kAudioUnitProperty_SetRenderCallback,
    /// AudioToolbox/AudioUnitProperties.h.
    const SET_RENDER_CALLBACK: u32 = 23;
    /// kAudioOutputUnitProperty_CurrentDevice,
    /// AudioToolbox/AudioUnitProperties.h.
    const CURRENT_DEVICE: u32 = 2000;
    /// kAudioUnitScope_Global, AudioToolbox/AudioUnitProperties.h.
    const UNIT_SCOPE_GLOBAL: u32 = 0;
    /// kAudioUnitScope_Input, AudioToolbox/AudioUnitProperties.h.
    const UNIT_SCOPE_INPUT: u32 = 1;
    /// kAudioFormatLinearPCM, CoreAudioTypes/CoreAudioBaseTypes.h.
    const LINEAR_PCM: u32 = code(b"lpcm");
    /// kAudioFormatFlagIsSignedInteger, CoreAudioTypes/CoreAudioBaseTypes.h.
    const SIGNED_INTEGER: u32 = 1 << 2;
    /// kAudioFormatFlagIsPacked, CoreAudioTypes/CoreAudioBaseTypes.h.
    const PACKED: u32 = 1 << 3;
    /// kAudioObjectSystemObject, CoreAudio/AudioHardware.h.
    const SYSTEM_OBJECT: AudioObjectID = 1;
    /// kAudioHardwarePropertyTranslateUIDToDevice, CoreAudio/AudioHardware.h.
    const TRANSLATE_UID_TO_DEVICE: u32 = code(b"uidd");
    /// kAudioObjectUnknown, CoreAudio/AudioHardwareBase.h.
    const UNKNOWN_OBJECT: AudioObjectID = 0;
    /// kAudioObjectPropertyScopeGlobal, CoreAudio/AudioHardwareBase.h.
    const OBJECT_SCOPE_GLOBAL: u32 = code(b"glob");
    /// kAudioObjectPropertyElementMain, CoreAudio/AudioHardwareBase.h.
    const ELEMENT_MAIN: u32 = 0;
    /// kCFStringEncodingUTF8, CoreFoundation/CFString.h.
    const UTF8: u32 = 0x0800_0100;

    /// AudioComponentDescription, AudioToolbox/AudioComponent.h.
    #[repr(C)]
    struct ComponentDescription {
        kind: u32,
        sub_kind: u32,
        manufacturer: u32,
        flags: u32,
        flags_mask: u32,
    }

    /// AudioStreamBasicDescription, CoreAudioTypes/CoreAudioBaseTypes.h.
    #[repr(C)]
    struct StreamDescription {
        sample_rate: f64,
        format: u32,
        format_flags: u32,
        bytes_per_packet: u32,
        frames_per_packet: u32,
        bytes_per_frame: u32,
        channels_per_frame: u32,
        bits_per_channel: u32,
        reserved: u32,
    }

    /// AudioBuffer, CoreAudioTypes/CoreAudioBaseTypes.h.
    #[repr(C)]
    struct Buffer {
        channels: u32,
        size: u32,
        data: *mut c_void,
    }

    /// AudioBufferList, CoreAudioTypes/CoreAudioBaseTypes.h: `count`
    /// buffers, of which C declares only the first.
    #[repr(C)]
    struct BufferList {
        count: u32,
        buffers: [Buffer; 1],
    }

    /// AURenderCallback, AudioToolbox/AUComponent.h.
    type RenderCallback = unsafe extern "C" fn(
        ref_con: *mut c_void,
        flags: *mut u32,
        time_stamp: *const c_void,
        bus: u32,
        frames: u32,
        data: *mut BufferList,
    ) -> OSStatus;

    /// AURenderCallbackStruct, AudioToolbox/AudioUnitProperties.h.
    #[repr(C)]
    struct RenderCallbackStruct {
        callback: RenderCallback,
        ref_con: *mut c_void,
    }

    /// AudioObjectPropertyAddress, CoreAudio/AudioHardwareBase.h.
    #[repr(C)]
    struct PropertyAddress {
        selector: u32,
        scope: u32,
        element: u32,
    }

    #[link(name = "AudioToolbox", kind = "framework")]
    unsafe extern "C" {
        // AudioToolbox/AudioComponent.h
        fn AudioComponentFindNext(
            component: AudioComponent,
            description: *const ComponentDescription,
        ) -> AudioComponent;
        fn AudioComponentInstanceNew(component: AudioComponent, unit: *mut AudioUnit) -> OSStatus;
        fn AudioComponentInstanceDispose(unit: AudioUnit) -> OSStatus;
        // AudioToolbox/AUComponent.h
        fn AudioUnitSetProperty(
            unit: AudioUnit,
            property: u32,
            scope: u32,
            element: u32,
            data: *const c_void,
            size: u32,
        ) -> OSStatus;
        fn AudioUnitInitialize(unit: AudioUnit) -> OSStatus;
        fn AudioUnitUninitialize(unit: AudioUnit) -> OSStatus;
        // AudioToolbox/AudioOutputUnit.h
        fn AudioOutputUnitStart(unit: AudioUnit) -> OSStatus;
        fn AudioOutputUnitStop(unit: AudioUnit) -> OSStatus;
    }

    #[link(name = "CoreAudio", kind = "framework")]
    unsafe extern "C" {
        // CoreAudio/AudioHardware.h
        fn AudioObjectGetPropertyData(
            object: AudioObjectID,
            address: *const PropertyAddress,
            qualifier_size: u32,
            qualifier: *const c_void,
            size: *mut u32,
            data: *mut c_void,
        ) -> OSStatus;
    }

    #[link(name = "CoreFoundation", kind = "framework")]
    unsafe extern "C" {
        // CoreFoundation/CFString.h
        fn CFStringCreateWithCString(
            allocator: *const c_void,
            string: *const c_char,
            encoding: u32,
        ) -> CFStringRef;
        // CoreFoundation/CFBase.h
        fn CFRelease(object: *const c_void);
    }

    /// What the render callback plays, handed to it as its refCon.
    struct Feed<'a> {
        pcm: &'a [u8],
        /// Bytes handed to CoreAudio so far; only the callback moves it.
        position: AtomicUsize,
        /// Set once a buffer is asked for after the last sample went out.
        done: AtomicBool,
    }

    pub fn play(pcm: &[u8], rate: u32, device: Option<&str>) -> bool {
        let feed = Box::new(Feed {
            pcm,
            position: AtomicUsize::new(0),
            done: AtomicBool::new(false),
        });
        let device = device.and_then(find_device);
        // The chosen output, or the default one when it went away.
        let mut output = open(device, rate, &feed);
        if output.is_none() && device.is_some() {
            output = open(None, rate, &feed);
        }
        let Some(output) = output else {
            return false;
        };
        // SAFETY: the unit is initialized and renders from `feed`, which
        // outlives it.
        if unsafe { AudioOutputUnitStart(output.0) } != 0 {
            return false;
        }
        // The cue's length and a second more, in case the device stalls.
        let length = Duration::from_millis(pcm.len() as u64 * 500 / u64::from(rate.max(1)));
        let deadline = Instant::now() + length + Duration::from_secs(1);
        while !feed.done.load(Ordering::Relaxed) && Instant::now() < deadline {
            sleep(Duration::from_millis(10));
        }
        // What the device itself still holds.
        sleep(Duration::from_millis(50));
        let played = feed.done.load(Ordering::Relaxed);
        // Stopped and gone before `feed` is.
        drop(output);
        played
    }

    /// The device whose UID is `uid`, if it is still there.
    fn find_device(uid: &str) -> Option<AudioObjectID> {
        let uid = CString::new(uid).ok()?;
        let address = PropertyAddress {
            selector: TRANSLATE_UID_TO_DEVICE,
            scope: OBJECT_SCOPE_GLOBAL,
            element: ELEMENT_MAIN,
        };
        let mut device = UNKNOWN_OBJECT;
        let mut size = size_of::<AudioObjectID>() as u32;
        // SAFETY: the CFString is made and released here and goes in as
        // the qualifier by address, as the property wants; `device` and
        // `size` take the answer.
        unsafe {
            let string = CFStringCreateWithCString(std::ptr::null(), uid.as_ptr(), UTF8);
            if string.is_null() {
                return None;
            }
            let status = AudioObjectGetPropertyData(
                SYSTEM_OBJECT,
                &address,
                size_of::<CFStringRef>() as u32,
                std::ptr::from_ref(&string).cast(),
                &mut size,
                std::ptr::from_mut(&mut device).cast(),
            );
            CFRelease(string);
            (status == 0 && device != UNKNOWN_OBJECT).then_some(device)
        }
    }

    /// An output unit, stopped and disposed of when dropped.
    struct Output(AudioUnit);

    impl Output {
        /// Sets `property` of element 0 in `scope` to `value`; true when
        /// the unit took it.
        fn set<T>(&self, property: u32, scope: u32, value: &T) -> bool {
            // SAFETY: `value` is a live T and its size goes along; every
            // caller passes the type `property` takes.
            unsafe {
                AudioUnitSetProperty(
                    self.0,
                    property,
                    scope,
                    0,
                    std::ptr::from_ref(value).cast(),
                    size_of::<T>() as u32,
                ) == 0
            }
        }

        fn initialize(&self) -> bool {
            // SAFETY: the unit is set up and not initialized yet.
            unsafe { AudioUnitInitialize(self.0) == 0 }
        }
    }

    impl Drop for Output {
        fn drop(&mut self) {
            // SAFETY: the unit came from AudioComponentInstanceNew and is
            // disposed of only here; stopping or uninitializing a unit
            // that never started or initialized does nothing.
            unsafe {
                AudioOutputUnitStop(self.0);
                AudioUnitUninitialize(self.0);
                AudioComponentInstanceDispose(self.0);
            }
        }
    }

    /// An output unit on `device` (the system's default output, and
    /// following it, when `None`) that plays from `feed`, ready to start.
    fn open(device: Option<AudioObjectID>, rate: u32, feed: &Feed<'_>) -> Option<Output> {
        let sub_kind = match device {
            Some(_) => HAL_OUTPUT,
            None => DEFAULT_OUTPUT,
        };
        let description = ComponentDescription {
            kind: TYPE_OUTPUT,
            sub_kind,
            manufacturer: APPLE,
            flags: 0,
            flags_mask: 0,
        };
        let mut unit: AudioUnit = std::ptr::null_mut();
        // SAFETY: a valid description, and somewhere for the instance.
        unsafe {
            let component = AudioComponentFindNext(std::ptr::null_mut(), &description);
            if component.is_null() || AudioComponentInstanceNew(component, &mut unit) != 0 {
                return None;
            }
        }
        let output = Output(unit);
        let format = StreamDescription {
            sample_rate: f64::from(rate),
            format: LINEAR_PCM,
            format_flags: SIGNED_INTEGER | PACKED,
            bytes_per_packet: 2,
            frames_per_packet: 1,
            bytes_per_frame: 2,
            channels_per_frame: 1,
            bits_per_channel: 16,
            reserved: 0,
        };
        let callback = RenderCallbackStruct {
            callback: render,
            ref_con: std::ptr::from_ref(feed).cast_mut().cast(),
        };
        let ready = device.is_none_or(|id| output.set(CURRENT_DEVICE, UNIT_SCOPE_GLOBAL, &id))
            && output.set(STREAM_FORMAT, UNIT_SCOPE_INPUT, &format)
            && output.set(SET_RENDER_CALLBACK, UNIT_SCOPE_INPUT, &callback)
            && output.initialize();
        ready.then_some(output)
    }

    /// Called on CoreAudio's real-time thread for every buffer the device
    /// wants: copies the next samples in and fills the rest with silence,
    /// with no locks and no allocations.
    unsafe extern "C" fn render(
        ref_con: *mut c_void,
        _flags: *mut u32,
        _time_stamp: *const c_void,
        _bus: u32,
        _frames: u32,
        data: *mut BufferList,
    ) -> OSStatus {
        // SAFETY: `ref_con` is the Feed that `play` keeps alive until the
        // unit is disposed of, and `data` lists `count` buffers CoreAudio
        // lends for the length of this call.
        unsafe {
            let feed = &*ref_con.cast::<Feed<'_>>();
            let position = feed.position.load(Ordering::Relaxed);
            if position >= feed.pcm.len() {
                feed.done.store(true, Ordering::Relaxed);
            }
            let mut rest = &feed.pcm[position.min(feed.pcm.len())..];
            let buffers = std::slice::from_raw_parts(
                (&raw const (*data).buffers).cast::<Buffer>(),
                (*data).count as usize,
            );
            for buffer in buffers {
                if buffer.data.is_null() {
                    continue;
                }
                let out =
                    std::slice::from_raw_parts_mut(buffer.data.cast::<u8>(), buffer.size as usize);
                let count = rest.len().min(out.len());
                out[..count].copy_from_slice(&rest[..count]);
                out[count..].fill(0);
                feed.position.fetch_add(count, Ordering::Relaxed);
                // Mono comes in one buffer; any other stays silent.
                rest = &[];
            }
        }
        0
    }
}
