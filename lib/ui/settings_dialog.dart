// Settings: the account's picture, which microphone, camera and speakers,
// voice processing, summons, notifications and, on desktops, keyboard
// shortcuts. The web client's Settings dialog, plus the app's own
// notification switches and shortcuts.

import 'dart:async';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:livekit_client/livekit_client.dart' as lk;

import '../data/api.dart';
import '../data/crash_reports.dart';
import '../data/gateway.dart';
import '../data/preferences.dart';
import '../data/shortcuts.dart';
import '../src/rust/api/picture.dart';
import '../theme.dart';
import 'common.dart';

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({
    super.key,
    required this.gateway,
    required this.preferences,
  });

  final Gateway gateway;
  final Preferences preferences;

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  List<lk.MediaDevice> _devices = [];
  StreamSubscription<List<lk.MediaDevice>>? _changes;
  bool? _allowSummons;
  bool _busy = false;
  String? _profileError;

  Preferences get _prefs => widget.preferences;
  Gateway get _gateway => widget.gateway;
  Api get _api => _gateway.session.api;
  bool get _account => !_gateway.session.me.isGuest;

  @override
  void initState() {
    super.initState();
    unawaited(_refresh());
    _changes = lk.Hardware.instance.onDeviceChange.stream.listen(
      (devices) => setState(() => _devices = devices),
    );
    if (_account) {
      _api
          .allowsSummons()
          .then((allow) {
            if (mounted) setState(() => _allowSummons = allow);
          })
          .catchError((Object _) {});
    }
  }

  @override
  void dispose() {
    unawaited(_changes?.cancel());
    super.dispose();
  }

  Future<void> _refresh() async {
    final devices = await lk.Hardware.instance.enumerateDevices();
    if (mounted) setState(() => _devices = devices);
  }

  List<lk.MediaDevice> _of(String kind) =>
      _devices.where((d) => d.kind == kind && d.deviceId.isNotEmpty).toList();

  Future<void> _pickPicture() async {
    final file = await openFile(
      acceptedTypeGroups: const [
        XTypeGroup(
          label: 'Pictures',
          extensions: ['png', 'jpg', 'jpeg', 'webp', 'gif'],
          mimeTypes: ['image/png', 'image/jpeg', 'image/webp', 'image/gif'],
          uniformTypeIdentifiers: ['public.image'],
        ),
      ],
    );
    if (file == null) return;
    setState(() {
      _busy = true;
      _profileError = null;
    });
    try {
      final (bytes, kind) = await prepareAvatar(
        bytes: await file.readAsBytes(),
      );
      final version = await _api.setAvatar(bytes, kind);
      _gateway.avatarChanged(version);
    } catch (e) {
      _profileError = e is ApiException
          ? e.message
          : 'Cannot upload the picture.';
    }
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _removePicture() async {
    setState(() {
      _busy = true;
      _profileError = null;
    });
    try {
      await _api.removeAvatar();
      _gateway.avatarChanged(null);
    } catch (e) {
      _profileError = 'Cannot remove the picture.';
    }
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _setAllowSummons(bool allow) async {
    setState(() => _allowSummons = allow);
    try {
      await _api.setAllowSummons(allow);
    } catch (_) {
      if (mounted) {
        setState(() => _allowSummons = !allow);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Cannot save.')));
      }
    }
  }

  void _change(void Function() edit) {
    setState(edit);
    _prefs.changed();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final me = _gateway.session.me;
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
              child: Text(
                'Settings',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: palette.text,
                ),
              ),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                children: [
                  if (_account) ...[
                    _Group(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              Avatar(
                                name: me.displayName,
                                size: 56,
                                image: _gateway.avatar(
                                  me.id,
                                  _gateway.myAvatar,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      me.displayName,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: palette.text,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 4,
                                      children: [
                                        OutlinedButton(
                                          onPressed: _busy
                                              ? null
                                              : _pickPicture,
                                          child: Text(
                                            _gateway.myAvatar == null
                                                ? 'Add Picture…'
                                                : 'Change Picture…',
                                          ),
                                        ),
                                        if (_gateway.myAvatar != null)
                                          TextButton(
                                            onPressed: _busy
                                                ? null
                                                : _removePicture,
                                            style: TextButton.styleFrom(
                                              foregroundColor: palette.error,
                                            ),
                                            child: const Text('Remove'),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (_profileError case final error?)
                      _Footer(error, color: palette.error),
                  ],
                  const _Header('Audio and Video'),
                  _Group(
                    children: [
                      _DeviceRow(
                        label: 'Microphone',
                        devices: _of('audioinput'),
                        value: _prefs.microphone,
                        onChanged: (id) =>
                            _change(() => _prefs.microphone = id),
                      ),
                      _DeviceRow(
                        label: 'Camera',
                        devices: _of('videoinput'),
                        value: _prefs.camera,
                        onChanged: (id) => _change(() => _prefs.camera = id),
                      ),
                      _DeviceRow(
                        label: 'Output',
                        devices: _of('audiooutput'),
                        value: _prefs.speaker,
                        onChanged: (id) => _change(() => _prefs.speaker = id),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _Group(
                    children: [
                      _SwitchRow(
                        label: 'Voice Processing',
                        detail: 'Noise suppression and echo cancellation',
                        value: _prefs.processing,
                        onChanged: (on) =>
                            _change(() => _prefs.processing = on),
                      ),
                    ],
                  ),
                  const _Footer(
                    'Turn it off for the best sound, and wear headphones then: '
                    'without echo cancellation others hear themselves through '
                    'your speakers.',
                  ),
                  const SizedBox(height: 14),
                  _Group(
                    children: [
                      _SwitchRow(
                        label: 'Join and Leave Sounds',
                        detail:
                            'An owl hoots when someone comes or goes, and '
                            'shortcuts tick',
                        value: _prefs.cues,
                        onChanged: (on) => _change(() => _prefs.cues = on),
                      ),
                    ],
                  ),
                  if (hasShortcuts) ...[
                    const _Header('Shortcuts'),
                    _ShortcutsGroup(preferences: _prefs),
                  ],
                  if (_account && _allowSummons != null) ...[
                    const _Header('Summons'),
                    _Group(
                      children: [
                        _SwitchRow(
                          label: 'Others May Summon Me',
                          value: _allowSummons!,
                          onChanged: _setAllowSummons,
                        ),
                      ],
                    ),
                  ],
                  const _Header('Notifications on This Device'),
                  _Group(
                    children: [
                      _SwitchRow(
                        label: 'New Messages',
                        detail: 'In your call’s chat and chats you opened',
                        value: _prefs.notifyMessages,
                        onChanged: (on) =>
                            _change(() => _prefs.notifyMessages = on),
                      ),
                      _SwitchRow(
                        label: 'Summons',
                        detail: 'When someone calls you into a channel',
                        value: _prefs.notifySummons,
                        onChanged: (on) =>
                            _change(() => _prefs.notifySummons = on),
                      ),
                    ],
                  ),
                  const _Footer('Shown while Wisetalk is in the background.'),
                  if (crashReports.available) ...[
                    const _Header('Privacy'),
                    _Group(
                      children: [
                        _SwitchRow(
                          label: 'Send Crash Reports',
                          value: _prefs.crashReports,
                          onChanged: (on) =>
                              _change(() => _prefs.crashReports = on),
                        ),
                      ],
                    ),
                    const _Footer(
                      'When something in Wisetalk breaks, tell its developers '
                      'what broke and where in the code. Never your messages, '
                      'names, keys or servers.',
                    ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
              child: Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Done'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Rounded rows with separators between them, as in iOS Settings.
class _Group extends StatelessWidget {
  const _Group({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    // Material, not a decorated box: switch rows paint their ink on it.
    return Material(
      color: palette.cell,
      clipBehavior: Clip.antiAlias,
      borderRadius: BorderRadius.circular(14),
      child: Column(
        children: [
          for (final (i, child) in children.indexed) ...[
            if (i > 0) Divider(height: 1, indent: 14, color: palette.separator),
            child,
          ],
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(14, 18, 14, 6),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: context.palette.muted,
      ),
    ),
  );
}

class _Footer extends StatelessWidget {
  const _Footer(this.text, {this.color});

  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(14, 6, 14, 0),
    child: Text(
      text,
      style: TextStyle(fontSize: 13, color: color ?? context.palette.muted),
    ),
  );
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.label,
    required this.value,
    required this.onChanged,
    this.detail,
  });

  final String label;
  final String? detail;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      title: Text(label, style: TextStyle(color: palette.text)),
      subtitle: detail == null
          ? null
          : Text(detail!, style: TextStyle(color: palette.muted, fontSize: 13)),
    );
  }
}

/// One row per call action with its keys. Clicking a row records the next
/// combination pressed; Backspace removes the shortcut, Esc keeps it.
class _ShortcutsGroup extends StatefulWidget {
  const _ShortcutsGroup({required this.preferences});

  final Preferences preferences;

  @override
  State<_ShortcutsGroup> createState() => _ShortcutsGroupState();
}

class _ShortcutsGroupState extends State<_ShortcutsGroup> {
  /// Takes the keys while recording, before the dialog sees Esc.
  final _focus = FocusNode(debugLabel: 'shortcut recorder');
  CallAction? _recording;
  String? _refusal;

  Preferences get _prefs => widget.preferences;

  @override
  void initState() {
    super.initState();
    // Clicking elsewhere stops recording.
    _focus.addListener(() {
      if (!_focus.hasFocus && _recording != null) {
        setState(() => _recording = null);
      }
    });
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  void _record(CallAction action) {
    setState(() {
      _recording = _recording == action ? null : action;
      _refusal = null;
    });
    if (_recording != null) _focus.requestFocus();
  }

  void _done([KeyCombo? combo, bool clear = false]) {
    final action = _recording;
    if (action != null && (combo != null || clear)) {
      _prefs.setShortcut(action, combo);
    }
    setState(() {
      _recording = null;
      _refusal = null;
    });
  }

  KeyEventResult _key(FocusNode node, KeyEvent event) {
    final action = _recording;
    if (action == null) return KeyEventResult.ignored;
    if (event is! KeyDownEvent) return KeyEventResult.handled;
    final combo = KeyCombo.fromEvent(event, HardwareKeyboard.instance);
    // Only modifiers so far: wait for the key.
    if (combo == null) return KeyEventResult.handled;
    if (combo == const KeyCombo(PhysicalKeyboardKey.escape)) {
      _done();
    } else if (combo == const KeyCombo(PhysicalKeyboardKey.backspace)) {
      _done(null, true);
    } else if (_refused(combo, action) case final refusal?) {
      setState(() => _refusal = refusal);
    } else {
      _done(combo);
    }
    return KeyEventResult.handled;
  }

  String? _refused(KeyCombo combo, CallAction action) {
    if (combo.refusal case final refusal?) return refusal;
    for (final other in CallAction.values) {
      if (other != action && _prefs.shortcut(other) == combo) {
        return '${combo.label} is already ${other.label}.';
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Focus(
          focusNode: _focus,
          onKeyEvent: _key,
          child: _Group(
            children: [
              for (final action in CallAction.values)
                _ShortcutRow(
                  action: action,
                  combo: _prefs.shortcut(action),
                  recording: _recording == action,
                  onTap: () => _record(action),
                ),
            ],
          ),
        ),
        if (_refusal case final refusal?)
          _Footer(refusal, color: palette.error)
        else if (_recording != null)
          const _Footer(
            'Press the new keys. Backspace removes the shortcut, '
            'Esc keeps it.',
          )
        else
          const _Footer(
            'They work while Wisetalk’s window is in front. Click one to '
            'change it.',
          ),
      ],
    );
  }
}

class _ShortcutRow extends StatelessWidget {
  const _ShortcutRow({
    required this.action,
    required this.combo,
    required this.recording,
    required this.onTap,
  });

  final CallAction action;
  final KeyCombo? combo;
  final bool recording;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final keys = recording ? 'Press keys…' : combo?.label ?? 'None';
    return ListTile(
      title: Text(action.label, style: TextStyle(color: palette.text)),
      trailing: DecoratedBox(
        decoration: BoxDecoration(
          color: recording
              ? palette.accent.withValues(alpha: 0.2)
              : palette.fill,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          child: Text(
            keys,
            style: TextStyle(
              color: recording || combo != null ? palette.text : palette.muted,
              fontSize: 13,
            ),
          ),
        ),
      ),
      onTap: onTap,
    );
  }
}

class _DeviceRow extends StatelessWidget {
  const _DeviceRow({
    required this.label,
    required this.devices,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final List<lk.MediaDevice> devices;
  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    // A device chosen earlier and unplugged since reads as the default.
    final current = devices.any((d) => d.deviceId == value) ? value : null;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Row(
        children: [
          Text(label, style: TextStyle(color: palette.text)),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButton<String?>(
              value: current,
              style: TextStyle(color: palette.text, fontSize: 14),
              isExpanded: true,
              underline: const SizedBox(),
              alignment: AlignmentDirectional.centerEnd,
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text(
                    'System Default',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                for (final device in devices)
                  DropdownMenuItem(
                    value: device.deviceId,
                    child: Text(
                      device.label.isEmpty ? label : device.label,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
