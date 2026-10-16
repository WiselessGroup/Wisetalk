//! The platform side of `api::hotkeys`, kept out of `api` so the bindings
//! generator doesn't publish it.

use crate::api::hotkeys::GlobalHotkey;
use crate::frb_generated::StreamSink;

pub(crate) use imp::{available, set, watch};

#[cfg(not(any(target_os = "windows", target_os = "macos", target_os = "linux")))]
mod imp {
    use super::{GlobalHotkey, StreamSink};

    pub fn available() -> bool {
        false
    }

    pub fn watch(_sink: StreamSink<String>) {}

    pub fn set(hotkeys: Vec<GlobalHotkey>) -> Vec<String> {
        hotkeys.into_iter().map(|h| h.action).collect()
    }
}

#[cfg(any(target_os = "windows", target_os = "macos", target_os = "linux"))]
mod imp {
    use std::cell::RefCell;
    use std::collections::{HashMap, HashSet};
    use std::sync::{Mutex, Once};

    use global_hotkey::hotkey::{Code, HotKey, Modifiers};
    use global_hotkey::{GlobalHotKeyEvent, GlobalHotKeyManager, HotKeyState};

    use super::{GlobalHotkey, StreamSink};

    /// Action of each registered shortcut, by the crate's hot key id.
    static ACTIONS: Mutex<Option<HashMap<u32, String>>> = Mutex::new(None);
    static SINK: Mutex<Option<StreamSink<String>>> = Mutex::new(None);
    /// Shortcuts down right now: a press counts once until released.
    static HELD: Mutex<Option<HashSet<u32>>> = Mutex::new(None);

    thread_local! {
        /// Lives on the thread the platform wants it on, see `on_its_thread`.
        static MANAGER: RefCell<Option<(GlobalHotKeyManager, Vec<HotKey>)>> =
            const { RefCell::new(None) };
    }

    pub fn available() -> bool {
        #[cfg(target_os = "linux")]
        {
            let wayland = std::env::var("XDG_SESSION_TYPE").is_ok_and(|t| t == "wayland")
                || std::env::var_os("WAYLAND_DISPLAY").is_some();
            !wayland && std::env::var_os("DISPLAY").is_some()
        }
        #[cfg(not(target_os = "linux"))]
        {
            true
        }
    }

    pub fn watch(sink: StreamSink<String>) {
        *SINK.lock().unwrap() = Some(sink);
        static HANDLER: Once = Once::new();
        HANDLER.call_once(|| {
            GlobalHotKeyEvent::set_event_handler(Some(|event: GlobalHotKeyEvent| {
                let mut held = HELD.lock().unwrap();
                let held = held.get_or_insert_with(HashSet::new);
                if event.state == HotKeyState::Released {
                    held.remove(&event.id);
                    return;
                }
                if !held.insert(event.id) {
                    return;
                }
                let action = ACTIONS
                    .lock()
                    .unwrap()
                    .as_ref()
                    .and_then(|a| a.get(&event.id).cloned());
                if let (Some(action), Some(sink)) = (action, SINK.lock().unwrap().as_ref()) {
                    let _ = sink.add(action);
                }
            }));
        });
    }

    pub fn set(hotkeys: Vec<GlobalHotkey>) -> Vec<String> {
        if !available() {
            return hotkeys.into_iter().map(|h| h.action).collect();
        }
        let mut failed = Vec::new();
        let mut wanted = Vec::new();
        for hotkey in hotkeys {
            match parse(&hotkey.combo) {
                Some(key) => wanted.push((key, hotkey.action)),
                None => failed.push(hotkey.action),
            }
        }
        let (actions, refused) = on_its_thread(move || {
            MANAGER.with_borrow_mut(|slot| {
                let mut actions = HashMap::new();
                let mut refused = Vec::new();
                if slot.is_none() {
                    match GlobalHotKeyManager::new() {
                        Ok(manager) => *slot = Some((manager, Vec::new())),
                        Err(e) => {
                            eprintln!("global shortcuts unavailable: {e}");
                            return (actions, wanted.into_iter().map(|(_, a)| a).collect());
                        }
                    }
                }
                let (manager, registered) = slot.as_mut().unwrap();
                let _ = manager.unregister_all(registered);
                registered.clear();
                for (key, action) in wanted {
                    match manager.register(key) {
                        Ok(()) => {
                            registered.push(key);
                            actions.insert(key.id(), action);
                        }
                        Err(e) => {
                            eprintln!("cannot register {key}: {e}");
                            refused.push(action);
                        }
                    }
                }
                (actions, refused)
            })
        });
        *ACTIONS.lock().unwrap() = Some(actions);
        if let Some(held) = HELD.lock().unwrap().as_mut() {
            held.clear();
        }
        failed.extend(refused);
        failed
    }

    /// macOS: Carbon hot keys belong to the main thread, whose run loop
    /// delivers them. The bridge calls this from a worker thread, never the
    /// main one, so waiting for the main queue can't deadlock.
    #[cfg(target_os = "macos")]
    fn on_its_thread<R: Send>(job: impl FnOnce() -> R + Send) -> R {
        let mut result = None;
        if unsafe { libc_pthread_main_np() } != 0 {
            result = Some(job());
        } else {
            dispatch2::DispatchQueue::main().exec_sync(|| result = Some(job()));
        }
        result.unwrap()
    }

    #[cfg(target_os = "macos")]
    unsafe extern "C" {
        #[link_name = "pthread_main_np"]
        fn libc_pthread_main_np() -> i32;
    }

    /// X11: the crate listens on a thread of its own; registering only has
    /// to happen on one thread, ours.
    #[cfg(target_os = "linux")]
    fn on_its_thread<R: Send + 'static>(job: impl FnOnce() -> R + Send + 'static) -> R {
        use std::sync::mpsc;
        type Job = Box<dyn FnOnce() + Send>;
        static JOBS: Mutex<Option<mpsc::Sender<Job>>> = Mutex::new(None);
        let (reply, answer) = mpsc::channel();
        let job: Job = Box::new(move || {
            let _ = reply.send(job());
        });
        let mut jobs = JOBS.lock().unwrap();
        let sender = jobs.get_or_insert_with(|| {
            let (sender, receiver) = mpsc::channel::<Job>();
            std::thread::Builder::new()
                .name("global-hotkeys".into())
                .spawn(move || {
                    for job in receiver {
                        job();
                    }
                })
                .expect("spawning the shortcuts thread");
            sender
        });
        sender.send(job).expect("the shortcuts thread is gone");
        drop(jobs);
        answer.recv().expect("the shortcuts thread is gone")
    }

    /// Windows: hot keys go to a window, and its thread must pump messages.
    /// Ours does nothing else; a job wakes it with WM_APP.
    #[cfg(target_os = "windows")]
    fn on_its_thread<R: Send + 'static>(job: impl FnOnce() -> R + Send + 'static) -> R {
        use std::sync::mpsc;
        use windows_sys::Win32::System::Threading::GetCurrentThreadId;
        use windows_sys::Win32::UI::WindowsAndMessaging::{
            DispatchMessageW, GetMessageW, MSG, PM_NOREMOVE, PeekMessageW, PostThreadMessageW,
            TranslateMessage, WM_APP, WM_USER,
        };
        type Job = Box<dyn FnOnce() + Send>;
        static THREAD: Mutex<Option<(u32, mpsc::Sender<Job>)>> = Mutex::new(None);

        let (reply, answer) = mpsc::channel();
        let job: Job = Box::new(move || {
            let _ = reply.send(job());
        });
        let mut thread = THREAD.lock().unwrap();
        let (id, sender) = thread.get_or_insert_with(|| {
            let (sender, receiver) = mpsc::channel::<Job>();
            let (ready, started) = mpsc::channel();
            std::thread::Builder::new()
                .name("global-hotkeys".into())
                .spawn(move || unsafe {
                    let mut msg: MSG = std::mem::zeroed();
                    // Makes the thread's message queue before anyone posts to it.
                    PeekMessageW(
                        &mut msg,
                        std::ptr::null_mut(),
                        WM_USER,
                        WM_USER,
                        PM_NOREMOVE,
                    );
                    let _ = ready.send(GetCurrentThreadId());
                    while GetMessageW(&mut msg, std::ptr::null_mut(), 0, 0) > 0 {
                        if msg.message == WM_APP && msg.hwnd.is_null() {
                            while let Ok(job) = receiver.try_recv() {
                                job();
                            }
                            continue;
                        }
                        TranslateMessage(&msg);
                        DispatchMessageW(&msg);
                    }
                })
                .expect("spawning the shortcuts thread");
            (
                started.recv().expect("the shortcuts thread did not start"),
                sender,
            )
        });
        sender.send(job).expect("the shortcuts thread is gone");
        unsafe { PostThreadMessageW(*id, WM_APP, 0, 0) };
        drop(thread);
        answer.recv().expect("the shortcuts thread is gone")
    }

    /// `control+shift+0x00070010` as the crate's hot key; `None` for what
    /// the app would never write.
    pub(super) fn parse(combo: &str) -> Option<HotKey> {
        let mut parts: Vec<&str> = combo.split('+').collect();
        let usage = u32::from_str_radix(parts.pop()?.strip_prefix("0x")?, 16).ok()?;
        let mut modifiers = Modifiers::empty();
        for part in parts {
            modifiers |= match part {
                "control" => Modifiers::CONTROL,
                "alt" => Modifiers::ALT,
                "shift" => Modifiers::SHIFT,
                "meta" => Modifiers::SUPER,
                _ => return None,
            };
        }
        let modifiers = (!modifiers.is_empty()).then_some(modifiers);
        Some(HotKey::new(modifiers, code(usage)?))
    }

    /// The keys the app lets a shortcut use (`_keyNames` in
    /// lib/data/shortcuts.dart), by USB HID usage.
    fn code(usage: u32) -> Option<Code> {
        const LETTERS: [Code; 26] = [
            Code::KeyA,
            Code::KeyB,
            Code::KeyC,
            Code::KeyD,
            Code::KeyE,
            Code::KeyF,
            Code::KeyG,
            Code::KeyH,
            Code::KeyI,
            Code::KeyJ,
            Code::KeyK,
            Code::KeyL,
            Code::KeyM,
            Code::KeyN,
            Code::KeyO,
            Code::KeyP,
            Code::KeyQ,
            Code::KeyR,
            Code::KeyS,
            Code::KeyT,
            Code::KeyU,
            Code::KeyV,
            Code::KeyW,
            Code::KeyX,
            Code::KeyY,
            Code::KeyZ,
        ];
        const DIGITS: [Code; 10] = [
            Code::Digit1,
            Code::Digit2,
            Code::Digit3,
            Code::Digit4,
            Code::Digit5,
            Code::Digit6,
            Code::Digit7,
            Code::Digit8,
            Code::Digit9,
            Code::Digit0,
        ];
        const FUNCTION: [Code; 12] = [
            Code::F1,
            Code::F2,
            Code::F3,
            Code::F4,
            Code::F5,
            Code::F6,
            Code::F7,
            Code::F8,
            Code::F9,
            Code::F10,
            Code::F11,
            Code::F12,
        ];
        const FUNCTION_HIGH: [Code; 12] = [
            Code::F13,
            Code::F14,
            Code::F15,
            Code::F16,
            Code::F17,
            Code::F18,
            Code::F19,
            Code::F20,
            Code::F21,
            Code::F22,
            Code::F23,
            Code::F24,
        ];
        const NUMPAD: [Code; 10] = [
            Code::Numpad1,
            Code::Numpad2,
            Code::Numpad3,
            Code::Numpad4,
            Code::Numpad5,
            Code::Numpad6,
            Code::Numpad7,
            Code::Numpad8,
            Code::Numpad9,
            Code::Numpad0,
        ];
        let page = usage.checked_sub(0x0007_0000)? as usize;
        Some(match page {
            0x04..=0x1d => LETTERS[page - 0x04],
            0x1e..=0x27 => DIGITS[page - 0x1e],
            0x28 => Code::Enter,
            0x29 => Code::Escape,
            0x2a => Code::Backspace,
            0x2b => Code::Tab,
            0x2c => Code::Space,
            0x2d => Code::Minus,
            0x2e => Code::Equal,
            0x2f => Code::BracketLeft,
            0x30 => Code::BracketRight,
            0x31 => Code::Backslash,
            0x33 => Code::Semicolon,
            0x34 => Code::Quote,
            0x35 => Code::Backquote,
            0x36 => Code::Comma,
            0x37 => Code::Period,
            0x38 => Code::Slash,
            0x3a..=0x45 => FUNCTION[page - 0x3a],
            0x46 => Code::PrintScreen,
            0x47 => Code::ScrollLock,
            0x48 => Code::Pause,
            0x49 => Code::Insert,
            0x4a => Code::Home,
            0x4b => Code::PageUp,
            0x4c => Code::Delete,
            0x4d => Code::End,
            0x4e => Code::PageDown,
            0x4f => Code::ArrowRight,
            0x50 => Code::ArrowLeft,
            0x51 => Code::ArrowDown,
            0x52 => Code::ArrowUp,
            0x54 => Code::NumpadDivide,
            0x55 => Code::NumpadMultiply,
            0x56 => Code::NumpadSubtract,
            0x57 => Code::NumpadAdd,
            0x58 => Code::NumpadEnter,
            0x59..=0x62 => NUMPAD[page - 0x59],
            0x63 => Code::NumpadDecimal,
            0x68..=0x73 => FUNCTION_HIGH[page - 0x68],
            _ => return None,
        })
    }
}

#[cfg(all(
    test,
    any(target_os = "windows", target_os = "macos", target_os = "linux")
))]
mod tests {
    use global_hotkey::hotkey::{Code, HotKey, Modifiers};

    use super::imp::parse;

    #[test]
    fn combos_read_as_the_app_writes_them() {
        assert_eq!(
            parse("control+shift+0x00070010"),
            Some(HotKey::new(
                Some(Modifiers::CONTROL | Modifiers::SHIFT),
                Code::KeyM
            ))
        );
        assert_eq!(
            parse("shift+meta+0x00070004"),
            Some(HotKey::new(
                Some(Modifiers::SHIFT | Modifiers::SUPER),
                Code::KeyA
            ))
        );
        assert_eq!(parse("0x0007003a"), Some(HotKey::new(None, Code::F1)));
        assert_eq!(
            parse("alt+0x00070027"),
            Some(HotKey::new(Some(Modifiers::ALT), Code::Digit0))
        );
        assert_eq!(parse("0x00070073"), Some(HotKey::new(None, Code::F24)));
        assert_eq!(parse("0x00070062"), Some(HotKey::new(None, Code::Numpad0)));
    }

    #[test]
    fn anything_else_is_refused() {
        for combo in [
            "",
            "control+",
            "hyper+0x00070010",
            "control+0x0007ffff",
            "control+0x00070032",
            "control+77",
            "control+0x000c00e9",
        ] {
            assert_eq!(parse(combo), None, "{combo}");
        }
    }
}
