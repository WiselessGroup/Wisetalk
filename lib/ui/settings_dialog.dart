// Settings: the account's picture, the interface's language, which
// microphone, camera and speakers, voice processing, summons, notifications
// (on Android with the app that brings them while Wisetalk is closed) and,
// on desktops, keyboard shortcuts. The web client's Settings dialog,
// plus the app's own notification switches and shortcuts. Everything
// applies as it changes, so the sheet has Done only.

import 'dart:async';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:livekit_client/livekit_client.dart' as lk;
import 'package:url_launcher/url_launcher.dart';

import '../data/api.dart';
import '../data/crash_reports.dart';
import '../data/gateway.dart';
import '../data/global_shortcuts.dart';
import '../data/input_filters.dart';
import '../data/language.dart';
import '../data/preferences.dart';
import '../data/shortcuts.dart';
import '../data/unified_push.dart';
import '../l10n/app_localizations.dart';
import '../src/rust/api/picture.dart';
import '../theme.dart';
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

  /// The push apps on this phone, once asked (Android, accounts).
  Distributors? _push;
  AppLifecycleListener? _lifecycle;

  Preferences get _prefs => widget.preferences;
  Gateway get _gateway => widget.gateway;
  Api get _api => _gateway.session.api;
  bool get _account => !_gateway.session.me.isGuest;
  bool get _pushes => unifiedPushes.available && _account;

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
    if (_pushes) {
      unawaited(_refreshPush());
      // Back from installing a push app, or from setting it up.
      _lifecycle = AppLifecycleListener(
        onResume: () => unawaited(_refreshPush(follow: true)),
      );
    }
  }

  @override
  void dispose() {
    unawaited(_changes?.cancel());
    _lifecycle?.dispose();
    super.dispose();
  }

  /// Asks which push apps there are; with [follow], one that just came
  /// gets this server's summons at once.
  Future<void> _refreshPush({bool follow = false}) async {
    var push = await unifiedPushes.distributors();
    if (follow &&
        push.chosen == null &&
        push.installed.isNotEmpty &&
        _prefs.notifySummons) {
      final session = _gateway.session;
      await unifiedPushes.follow(session.server.origin, session.token);
      push = await unifiedPushes.distributors();
    }
    if (mounted) setState(() => _push = push);
  }

  Future<void> _choosePush(String distributor) async {
    final installed = _push?.installed ?? const <String>[];
    setState(() => _push = (installed: installed, chosen: distributor));
    final session = _gateway.session;
    await unifiedPushes.choose(
      distributor,
      session.server.origin,
      session.token,
    );
  }

  /// Summons on or off here: on Android, every server's pushes too.
  void _setNotifySummons(bool on) {
    _change(() => _prefs.notifySummons = on);
    if (!unifiedPushes.available) return;
    if (!on) {
      unawaited(unifiedPushes.forgetAll());
    } else if (_account) {
      final session = _gateway.session;
      unawaited(unifiedPushes.follow(session.server.origin, session.token));
    }
  }

  Future<void> _refresh() async {
    final devices = await lk.Hardware.instance.enumerateDevices();
    if (mounted) setState(() => _devices = devices);
  }

  List<lk.MediaDevice> _of(String kind) =>
      _devices.where((d) => d.kind == kind && d.deviceId.isNotEmpty).toList();

  Future<void> _pickPicture() async {
    final texts = AppLocalizations.of(context);
    final file = await openFile(
      acceptedTypeGroups: [
        XTypeGroup(
          label: texts.settingsPictures,
          extensions: const ['png', 'jpg', 'jpeg', 'webp', 'gif'],
          mimeTypes: const [
            'image/png',
            'image/jpeg',
            'image/webp',
            'image/gif',
          ],
          uniformTypeIdentifiers: const ['public.image'],
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
      _profileError = e is ApiException ? e.message : texts.profileUploadFailed;
    }
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _removePicture() async {
    final texts = AppLocalizations.of(context);
    setState(() {
      _busy = true;
      _profileError = null;
    });
    try {
      await _api.removeAvatar();
      _gateway.avatarChanged(null);
    } catch (e) {
      _profileError = texts.profileRemoveFailed;
    }
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _setAllowSummons(bool allow) async {
    final texts = AppLocalizations.of(context);
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
          _summonsError = texts.saveFailed;
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
        (null, AppLocalizations.of(context).settingsSystemDefault),
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
    final texts = AppLocalizations.of(context);
    final language = _prefs.language.value;
    return SettingsSheet(
      title: texts.settingsTitle,
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
                label: picture == null
                    ? texts.profileAddPicture
                    : texts.profileChangePicture,
                onTap: _busy ? null : _pickPicture,
              ),
              if (picture != null)
                ButtonRow(
                  label: texts.profileRemovePicture,
                  destructive: true,
                  onTap: _busy ? null : _removePicture,
                ),
            ],
          ),
        // Each language's name is written in that language, to be found by
        // whoever reads it. Picking one turns the whole app at once.
        SettingsGroup(
          children: [
            PickerRow<String?>(
              label: texts.settingsLanguage,
              value: languages.containsKey(language) ? language : null,
              options: [
                (null, texts.settingsSystemDefault),
                for (final MapEntry(:key, :value) in languages.entries)
                  (key, value),
              ],
              optionLocale: (tag) => tag == null ? null : localeOf(tag),
              onChanged: (tag) => _change(() => _prefs.language.value = tag),
            ),
          ],
        ),
        SettingsGroup(
          header: texts.settingsAudioVideo,
          children: [
            _device(
              texts.settingsMicrophone,
              'audioinput',
              _prefs.microphone,
              (id) => _prefs.microphone = id,
            ),
            _device(
              texts.settingsCamera,
              'videoinput',
              _prefs.camera,
              (id) => _prefs.camera = id,
            ),
            _device(
              texts.settingsOutput,
              'audiooutput',
              _prefs.speaker,
              (id) => _prefs.speaker = id,
            ),
          ],
        ),
        // Where the device filters the microphone itself there is
        // nothing to choose (WLK-2).
        if (!inputFilters.byDevice)
          SettingsGroup(
            footer: texts.settingsVoiceProcessingHint,
            children: [
              SwitchRow(
                label: texts.settingsVoiceProcessing,
                detail: texts.settingsVoiceProcessingDetail,
                value: _prefs.processing,
                onChanged: (on) => _change(() => _prefs.processing = on),
              ),
            ],
          ),
        SettingsGroup(
          children: [
            SwitchRow(
              label: texts.settingsCues,
              detail: texts.settingsCuesDetail,
              value: _prefs.cues,
              onChanged: (on) => _change(() => _prefs.cues = on),
            ),
            SwitchRow(
              label: texts.settingsPingAndLoss,
              detail: texts.settingsPingAndLossDetail,
              value: _prefs.showPingAndLoss,
              onChanged: (on) => _change(() => _prefs.showPingAndLoss = on),
            ),
          ],
        ),
        if (hasShortcuts) _ShortcutsGroup(preferences: _prefs),
        if (_account && _allowSummons != null)
          SettingsGroup(
            header: texts.summonsHeader,
            error: _summonsError,
            children: [
              SwitchRow(
                label: texts.summonsAllow,
                value: _allowSummons!,
                onChanged: _setAllowSummons,
              ),
            ],
          ),
        SettingsGroup(
          header: texts.settingsNotificationsHere,
          footer: texts.settingsNotificationsHint,
          children: [
            SwitchRow(
              label: texts.settingsNotifyMessages,
              detail: texts.settingsNotifyMessagesDetail,
              value: _prefs.notifyMessages,
              onChanged: (on) => _change(() => _prefs.notifyMessages = on),
            ),
            SwitchRow(
              label: texts.settingsNotifySummons,
              detail: texts.settingsNotifySummonsDetail,
              value: _prefs.notifySummons,
              onChanged: _setNotifySummons,
            ),
          ],
        ),
        if (_push case final push? when _prefs.notifySummons)
          _pushGroup(texts, push),
        if (crashReports.available)
          SettingsGroup(
            header: texts.settingsPrivacy,
            footer: texts.settingsCrashReportsHint,
            children: [
              SwitchRow(
                label: texts.settingsCrashReports,
                value: _prefs.crashReports,
                onChanged: (on) => _change(() => _prefs.crashReports = on),
              ),
            ],
          ),
      ],
    );
  }

  /// Which app brings summons while Wisetalk is closed: its name, a choice
  /// when there are several, or where to get ntfy when there is none.
  Widget _pushGroup(AppLocalizations texts, Distributors push) {
    // One chosen and uninstalled since counts as none.
    final chosen = push.installed.contains(push.chosen) ? push.chosen : null;
    final String footer;
    final List<Widget> rows;
    if (push.installed.isEmpty) {
      footer = texts.settingsPushNoneHint;
      rows = [
        SettingsRow(
          label: texts.settingsPushApp,
          value: texts.settingsPushAppNone,
        ),
        ButtonRow(
          label: texts.settingsGetNtfy,
          onTap: () => unawaited(
            launchUrl(ntfyStorePage, mode: LaunchMode.externalApplication),
          ),
        ),
      ];
    } else if (push.installed.length == 1 && chosen != null) {
      footer = texts.settingsPushVia(distributorName(chosen));
      rows = [
        SettingsRow(
          label: texts.settingsPushApp,
          value: distributorName(chosen),
        ),
      ];
    } else {
      footer = chosen == null
          ? texts.settingsPushChooseHint
          : texts.settingsPushVia(distributorName(chosen));
      rows = [
        PickerRow<String?>(
          label: texts.settingsPushApp,
          value: chosen,
          options: [
            if (chosen == null) (null, texts.settingsPushAppChoose),
            for (final distributor in push.installed)
              (distributor, distributorName(distributor)),
          ],
          onChanged: (distributor) {
            if (distributor != null) unawaited(_choosePush(distributor));
          },
        ),
      ];
    }
    return SettingsGroup(
      header: texts.settingsPushHeader,
      footer: footer,
      children: rows,
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
  /// Takes the keys while recording, before the sheet sees Esc.
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
    final texts = AppLocalizations.of(context);
    if (combo.refusalText(texts) case final refusal?) return refusal;
    for (final other in CallAction.values) {
      if (other != action && _prefs.shortcut(other) == combo) {
        return texts.settingsShortcutTaken(combo.label, other.label(texts));
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context);
    return Focus(
      focusNode: _focus,
      onKeyEvent: _key,
      child: SettingsGroup(
        header: texts.settingsShortcuts,
        error: _refusal,
        footer: _recording != null
            ? texts.settingsShortcutsRecording
            : globalShortcutsAvailable
            ? texts.settingsShortcutsGlobal
            : texts.settingsShortcutsWayland,
        children: [
          for (final action in CallAction.values)
            SettingsRow(
              label: action.label(texts),
              trailing: _Keys(
                recording: _recording == action,
                combo: _prefs.shortcut(action),
              ),
              onTap: () => _record(action),
            ),
        ],
      ),
    );
  }
}

/// The keys of one shortcut, or what recording is waiting for.
class _Keys extends StatelessWidget {
  const _Keys({required this.recording, required this.combo});

  final bool recording;
  final KeyCombo? combo;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final texts = AppLocalizations.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: recording ? palette.accent.withValues(alpha: 0.2) : palette.fill,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        child: Text(
          recording
              ? texts.settingsShortcutPressKeys
              : combo?.label ?? texts.settingsShortcutNone,
          style: TextStyle(
            color: recording || combo != null ? palette.text : palette.muted,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
