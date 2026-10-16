//! Shortcuts that work while another app is in front (WLK-30, ADR-0027):
//! RegisterHotKey on Windows, Carbon hot keys on macOS, XGrabKey on X11,
//! through the `global-hotkey` crate. The app registers them only while it
//! is in a call. Wayland lets no app grab keys (that is WLK-31's portal):
//! there nothing is registered and [`global_hotkeys_available`] says so.
//!
//! Bindings come as the app keeps them: `control+shift+0x00070010`, the
//! modifiers and the physical key's USB HID usage.

use crate::frb_generated::StreamSink;

/// One shortcut: the action's name and its key combination.
pub struct GlobalHotkey {
    pub action: String,
    pub combo: String,
}

/// Whether this desktop lets the app have global shortcuts at all.
#[flutter_rust_bridge::frb(sync)]
pub fn global_hotkeys_available() -> bool {
    crate::hotkeys::available()
}

/// Sends the action of every global shortcut pressed, once per press: held
/// keys don't repeat.
pub fn watch_global_hotkeys(sink: StreamSink<String>) {
    crate::hotkeys::watch(sink);
}

/// Replaces the registered shortcuts with `hotkeys`; none to unregister them
/// all. Returns the actions whose combination could not be registered,
/// usually because another app holds it.
pub fn set_global_hotkeys(hotkeys: Vec<GlobalHotkey>) -> Vec<String> {
    crate::hotkeys::set(hotkeys)
}
