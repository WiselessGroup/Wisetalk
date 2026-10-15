// Settings: the account's picture, which microphone, camera and speakers,
// voice processing, summons and notifications. The web client's Settings
// dialog, plus the app's own notification switches. Everything applies as
// it changes, so the sheet has Done only.

import 'dart:async';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart' as lk;

import '../data/api.dart';
import '../data/crash_reports.dart';
import '../data/gateway.dart';
import '../data/preferences.dart';
import '../src/rust/api/picture.dart';
import 'common.dart';
import 'settings_sheet.dart';

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
  String? _summonsError;

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
    setState(() {
      _allowSummons = allow;
      _summonsError = null;
    });
    try {
      await _api.setAllowSummons(allow);
    } catch (_) {
      if (mounted) {
        setState(() {
          _allowSummons = !allow;
          _summonsError = 'Cannot save.';
        });
      }
    }
  }

  void _change(void Function() edit) {
    setState(edit);
    _prefs.changed();
  }

  /// Which microphone, camera or speakers: the system's own, or one of
  /// those plugged in. One chosen earlier and unplugged since reads as the
  /// default.
  Widget _device(
    String label,
    String kind,
    String? value,
    void Function(String?) set,
  ) {
    final devices = _of(kind);
    return PickerRow<String?>(
      label: label,
      value: devices.any((d) => d.deviceId == value) ? value : null,
      options: [
        (null, 'System Default'),
        for (final d in devices)
          (d.deviceId, d.label.isEmpty ? label : d.label),
      ],
      onChanged: (id) => _change(() => set(id)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final me = _gateway.session.me;
    final picture = _gateway.myAvatar;
    return SettingsSheet(
      title: 'Settings',
      children: [
        if (_account)
          SettingsGroup(
            error: _profileError,
            children: [
              SettingsRow(
                leading: Avatar(
                  name: me.displayName,
                  size: 56,
                  image: _gateway.avatar(me.id, picture),
                ),
                label: me.displayName,
                detail: me.username == null ? null : '@${me.username}',
              ),
              ButtonRow(
                label: picture == null ? 'Add Picture…' : 'Change Picture…',
                onTap: _busy ? null : _pickPicture,
              ),
              if (picture != null)
                ButtonRow(
                  label: 'Remove Picture',
                  destructive: true,
                  onTap: _busy ? null : _removePicture,
                ),
            ],
          ),
        SettingsGroup(
          header: 'Audio and Video',
          children: [
            _device(
              'Microphone',
              'audioinput',
              _prefs.microphone,
              (id) => _prefs.microphone = id,
            ),
            _device(
              'Camera',
              'videoinput',
              _prefs.camera,
              (id) => _prefs.camera = id,
            ),
            _device(
              'Output',
              'audiooutput',
              _prefs.speaker,
              (id) => _prefs.speaker = id,
            ),
          ],
        ),
        SettingsGroup(
          footer:
              'Turn it off for the best sound, and wear headphones then: '
              'without echo cancellation others hear themselves through '
              'your speakers.',
          children: [
            SwitchRow(
              label: 'Voice Processing',
              detail: 'Noise suppression and echo cancellation',
              value: _prefs.processing,
              onChanged: (on) => _change(() => _prefs.processing = on),
            ),
          ],
        ),
        SettingsGroup(
          children: [
            SwitchRow(
              label: 'Join and Leave Sounds',
              detail: 'An owl hoots when someone comes or goes',
              value: _prefs.cues,
              onChanged: (on) => _change(() => _prefs.cues = on),
            ),
          ],
        ),
        if (_account && _allowSummons != null)
          SettingsGroup(
            header: 'Summons',
            error: _summonsError,
            children: [
              SwitchRow(
                label: 'Others May Summon Me',
                value: _allowSummons!,
                onChanged: _setAllowSummons,
              ),
            ],
          ),
        SettingsGroup(
          header: 'Notifications on This Device',
          footer: 'Shown while Wisetalk is in the background.',
          children: [
            SwitchRow(
              label: 'New Messages',
              detail: 'In your call’s chat and chats you opened',
              value: _prefs.notifyMessages,
              onChanged: (on) => _change(() => _prefs.notifyMessages = on),
            ),
            SwitchRow(
              label: 'Summons',
              detail: 'When someone calls you into a channel',
              value: _prefs.notifySummons,
              onChanged: (on) => _change(() => _prefs.notifySummons = on),
            ),
          ],
        ),
        if (crashReports.available)
          SettingsGroup(
            header: 'Privacy',
            footer:
                'When something in Wisetalk breaks, tell its developers '
                'what broke and where in the code. Never your messages, '
                'names, keys or servers.',
            children: [
              SwitchRow(
                label: 'Send Crash Reports',
                value: _prefs.crashReports,
                onChanged: (on) => _change(() => _prefs.crashReports = on),
              ),
            ],
          ),
      ],
    );
  }
}
