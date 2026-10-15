// Keyboard shortcuts for the call (ADR-0027): what each one does, what it
// is bound to, and how a binding is written down in the preferences.
// Desktop only; phones have no shortcuts.
//
// A binding names the physical key, the place on the keyboard, rather than
// the letter it types: Ctrl+Shift+M stays the same key with a Russian
// layout on, and global shortcuts (WLK-30) grab physical keys anyway.

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Whether keys are labelled the Apple way: ⌘ for Command, and so on.
bool get _apple =>
    defaultTargetPlatform == TargetPlatform.macOS ||
    defaultTargetPlatform == TargetPlatform.iOS;

/// What a shortcut can do in a call.
enum CallAction {
  toggleMute('Microphone On or Off', 0x00070010), // M
  toggleAway('Away or Back', 0x00070004), // A
  mute('Microphone Off', null),
  unmute('Microphone On', null);

  const CallAction(this.label, this._defaultKey);

  final String label;
  final int? _defaultKey;

  /// Ctrl+Shift+M and Ctrl+Shift+A, with Command for Ctrl on a Mac; the
  /// one-way actions start unbound.
  KeyCombo? get defaultCombo {
    final key = _defaultKey;
    if (key == null) return null;
    return KeyCombo(
      PhysicalKeyboardKey(key),
      control: !_apple,
      meta: _apple,
      shift: true,
    );
  }
}

/// A key with the modifiers held while pressing it.
@immutable
class KeyCombo {
  const KeyCombo(
    this.key, {
    this.control = false,
    this.alt = false,
    this.shift = false,
    this.meta = false,
  });

  final PhysicalKeyboardKey key;
  final bool control;
  final bool alt;
  final bool shift;

  /// Command on a Mac, the Windows or Super key elsewhere.
  final bool meta;

  /// The combination just pressed, or `null` while only modifiers are down.
  static KeyCombo? fromEvent(KeyEvent event, HardwareKeyboard keyboard) {
    if (_modifierKeys.contains(event.physicalKey)) return null;
    return KeyCombo(
      event.physicalKey,
      control: keyboard.isControlPressed,
      alt: keyboard.isAltPressed,
      shift: keyboard.isShiftPressed,
      meta: keyboard.isMetaPressed,
    );
  }

  /// Reads what [toString] wrote; `null` for anything else.
  static KeyCombo? parse(String text) {
    final parts = text.split('+');
    final usage = int.tryParse(parts.last);
    final modifiers = parts.sublist(0, parts.length - 1).toSet();
    if (usage == null ||
        _keyNames[usage] == null ||
        !modifiers.every(_modifierNames.contains) ||
        modifiers.length != parts.length - 1) {
      return null;
    }
    return KeyCombo(
      PhysicalKeyboardKey(usage),
      control: modifiers.contains('control'),
      alt: modifiers.contains('alt'),
      shift: modifiers.contains('shift'),
      meta: modifiers.contains('meta'),
    );
  }

  /// How the preferences keep it: `control+shift+0x00070010`.
  @override
  String toString() => [
    if (control) 'control',
    if (alt) 'alt',
    if (shift) 'shift',
    if (meta) 'meta',
    '0x${key.usbHidUsage.toRadixString(16).padLeft(8, '0')}',
  ].join('+');

  /// What people read: ⌃⌥⇧⌘M on a Mac, Ctrl+Alt+Shift+Super+M elsewhere.
  String get label {
    final usage = key.usbHidUsage;
    final name =
        (_apple ? _appleKeyNames[usage] : null) ?? _keyNames[usage] ?? '?';
    if (_apple) {
      return [
        if (control) '⌃',
        if (alt) '⌥',
        if (shift) '⇧',
        if (meta) '⌘',
        name,
      ].join();
    }
    final windows = defaultTargetPlatform == TargetPlatform.windows;
    return [
      if (control) 'Ctrl',
      if (alt) 'Alt',
      if (shift) 'Shift',
      if (meta) windows ? 'Win' : 'Super',
      name,
    ].join('+');
  }

  /// Whether [keyboard] holds exactly these modifiers.
  bool heldIn(HardwareKeyboard keyboard) =>
      keyboard.isControlPressed == control &&
      keyboard.isAltPressed == alt &&
      keyboard.isShiftPressed == shift &&
      keyboard.isMetaPressed == meta;

  bool get _functionKey =>
      (key.usbHidUsage >= 0x0007003a && key.usbHidUsage <= 0x00070045) ||
      (key.usbHidUsage >= 0x00070068 && key.usbHidUsage <= 0x00070073);

  /// Why this can't be a shortcut, or `null` when it can. Refuses what the
  /// system or every app already uses, and plain keys that type text.
  String? get refusal {
    if (_keyNames[key.usbHidUsage] == null) {
      return 'That key can’t be used for a shortcut.';
    }
    // Shift alone, or Option on a Mac, still types: the chat would lose
    // the letter.
    final typing = _apple ? !control && !meta : !control && !alt && !meta;
    if (typing && !_functionKey) {
      return _apple
          ? 'Add ⌘ or ⌃, or use F1 to F24.'
          : 'Add Ctrl or Alt, or use F1 to F24.';
    }
    final reserved = _apple ? _reservedApple : _reservedElsewhere;
    if (reserved.contains(toString())) {
      return '$label belongs to the system or to every app.';
    }
    return null;
  }

  @override
  bool operator ==(Object other) =>
      other is KeyCombo &&
      other.key == key &&
      other.control == control &&
      other.alt == alt &&
      other.shift == shift &&
      other.meta == meta;

  @override
  int get hashCode => Object.hash(key, control, alt, shift, meta);
}

const _modifierNames = {'control', 'alt', 'shift', 'meta'};

final _modifierKeys = {
  PhysicalKeyboardKey.controlLeft,
  PhysicalKeyboardKey.controlRight,
  PhysicalKeyboardKey.altLeft,
  PhysicalKeyboardKey.altRight,
  PhysicalKeyboardKey.shiftLeft,
  PhysicalKeyboardKey.shiftRight,
  PhysicalKeyboardKey.metaLeft,
  PhysicalKeyboardKey.metaRight,
  PhysicalKeyboardKey.capsLock,
  PhysicalKeyboardKey.fn,
};

/// The keys a shortcut may use, by USB HID usage (what
/// [PhysicalKeyboardKey] holds), with the names shown for them. Flutter
/// names physical keys only in debug builds.
final Map<int, String> _keyNames = {
  for (var i = 0; i < 26; i++) 0x00070004 + i: String.fromCharCode(65 + i),
  for (var i = 0; i < 9; i++) 0x0007001e + i: '${i + 1}',
  0x00070027: '0',
  0x00070028: 'Enter',
  0x00070029: 'Esc',
  0x0007002a: 'Backspace',
  0x0007002b: 'Tab',
  0x0007002c: 'Space',
  0x0007002d: '-',
  0x0007002e: '=',
  0x0007002f: '[',
  0x00070030: ']',
  0x00070031: r'\',
  0x00070033: ';',
  0x00070034: "'",
  0x00070035: '`',
  0x00070036: ',',
  0x00070037: '.',
  0x00070038: '/',
  for (var i = 0; i < 12; i++) 0x0007003a + i: 'F${i + 1}',
  0x00070046: 'Print Screen',
  0x00070047: 'Scroll Lock',
  0x00070048: 'Pause',
  0x00070049: 'Insert',
  0x0007004a: 'Home',
  0x0007004b: 'Page Up',
  0x0007004c: 'Delete',
  0x0007004d: 'End',
  0x0007004e: 'Page Down',
  0x0007004f: '→',
  0x00070050: '←',
  0x00070051: '↓',
  0x00070052: '↑',
  0x00070054: 'Num /',
  0x00070055: 'Num *',
  0x00070056: 'Num -',
  0x00070057: 'Num +',
  0x00070058: 'Num Enter',
  for (var i = 0; i < 9; i++) 0x00070059 + i: 'Num ${i + 1}',
  0x00070062: 'Num 0',
  0x00070063: 'Num .',
  for (var i = 0; i < 12; i++) 0x00070068 + i: 'F${i + 13}',
};

/// The same keys as a Mac labels them.
const Map<int, String> _appleKeyNames = {
  0x00070028: '↩',
  0x00070029: '⎋',
  0x0007002a: '⌫',
  0x0007002b: '⇥',
  0x0007004c: '⌦',
};

/// Written as [KeyCombo.toString] does, by the key's usage.
String _combo(List<String> modifiers, int usage) =>
    [...modifiers, '0x${usage.toRadixString(16).padLeft(8, '0')}'].join('+');

int _letter(String letter) => 0x00070004 + letter.codeUnitAt(0) - 65;

/// macOS: quit, close, settings, hide, minimize, the app and window
/// switchers, Spotlight, screenshots, force quit, lock and log out, and
/// the editing keys every app has.
final Set<String> _reservedApple = {
  for (final letter in 'QWHMNTOPSAZXCVF'.split(''))
    _combo(['meta'], _letter(letter)),
  _combo(['meta'], 0x00070036), // ⌘,
  _combo(['meta'], 0x0007002b), // ⌘⇥
  _combo(['meta'], 0x00070035), // ⌘`
  _combo(['meta'], 0x0007002c), // ⌘Space
  _combo(['control'], 0x0007002c), // ⌃Space, input sources
  _combo(['shift', 'meta'], _letter('Z')),
  _combo(['shift', 'meta'], _letter('Q')),
  for (final digit in [0x00070020, 0x00070021, 0x00070022]) // 3, 4, 5
    _combo(['shift', 'meta'], digit),
  _combo(['alt', 'meta'], 0x00070029), // ⌥⌘⎋
  _combo(['alt', 'meta'], _letter('D')),
  _combo(['control', 'meta'], _letter('Q')),
  _combo(['control', 'meta'], _letter('F')),
  _combo(['control', 'meta'], 0x0007002c), // ⌃⌘Space, emoji
};

/// Windows and Linux: closing and quitting, the switchers, the session's
/// own keys, and the editing keys every app has.
final Set<String> _reservedElsewhere = {
  for (final letter in 'QWNTOPSAZXCVFY'.split(''))
    _combo(['control'], _letter(letter)),
  _combo(['control', 'shift'], _letter('Z')),
  _combo(['control', 'shift'], 0x00070029), // Ctrl+Shift+Esc
  _combo(['control'], 0x00070029), // Ctrl+Esc
  _combo(['alt'], 0x0007003d), // Alt+F4
  _combo(['alt'], 0x0007002b), // Alt+Tab
  _combo(['alt', 'shift'], 0x0007002b),
  _combo(['alt'], 0x0007002c), // Alt+Space, the window menu
  _combo(['control', 'alt'], 0x0007004c), // Ctrl+Alt+Delete
  _combo(['control', 'alt'], _letter('T')), // a terminal on many desktops
  _combo(['control', 'alt'], _letter('L')), // lock on many desktops
  for (var i = 0; i < 12; i++) // switching to a text console
    _combo(['control', 'alt'], 0x0007003a + i),
  for (final letter in 'LDEMRSTXIAV'.split(''))
    _combo(['meta'], _letter(letter)),
  _combo(['meta'], 0x0007002b), // Win+Tab
  _combo(['meta'], 0x0007002c), // Win+Space, input sources
  _combo(['shift', 'meta'], _letter('S')), // screenshots on Windows
};

/// Whether this device has shortcuts at all: desktops do, phones don't.
bool get hasShortcuts => const {
  TargetPlatform.linux,
  TargetPlatform.macOS,
  TargetPlatform.windows,
}.contains(defaultTargetPlatform);
