// What a person sets for themselves on this device: which microphone,
// camera and speakers, voice processing, how loud each person in a call is
// for them, which notifications to show, whether to show ping and loss,
// which spaces are folded, the keyboard shortcuts and the interface's
// language. The web client's Preferences, plus what only the app has.

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'crash_reports.dart' as reports;
import 'language.dart';
import 'protocol.dart';
import 'secrets.dart';
import 'servers.dart';
import 'shortcuts.dart';

const _key = 'preferences';

/// Stable key for per-person settings: the account, or the name for guests.
String personKey(Participant p) => p.account ?? 'guest:${p.displayName}';

class Preferences extends ChangeNotifier {
  Preferences(this._secrets) {
    language.addListener(() => appLanguage = language.value);
  }

  final Secrets _secrets;

  /// Device ids; `null` follows the system's default.
  String? microphone;
  String? camera;
  String? speaker;

  /// Noise suppression, echo cancellation and automatic gain. Needs
  /// headphones when off.
  bool processing = true;

  /// Per person (see [personKey]): 0 to 2, 1 is unchanged.
  Map<String, double> volumes = {};

  /// Per person: muted only for me.
  Set<String> silenced = {};

  /// Hoot when someone comes into or leaves my call, and tick when a
  /// shortcut turns something on or off.
  bool cues = true;

  /// Shortcuts bound to something other than their default; `null` for
  /// none at all. See [shortcut].
  Map<CallAction, KeyCombo?> shortcutChanges = {};

  /// System notifications while Wisetalk is in the background.
  bool notifyMessages = true;
  bool notifySummons = true;

  /// Ping and loss next to the connection icon in a call, measured once a
  /// second while the window shows. Off: the icon alone costs nothing.
  bool showPingAndLoss = false;

  /// Share the sound with a screen or window, where the app can (Windows).
  bool screenSound = true;

  /// Send crash reports to the developers; off unless turned on.
  bool crashReports = false;

  /// Spaces folded in the channel list.
  Set<String> collapsed = {};

  /// What [action] is bound to now, if anything.
  KeyCombo? shortcut(CallAction action) => shortcutChanges.containsKey(action)
      ? shortcutChanges[action]
      : action.defaultCombo;

  /// Binds [action] to [combo] (`null` for nothing), and saves.
  void setShortcut(CallAction action, KeyCombo? combo) {
    if (combo == action.defaultCombo) {
      shortcutChanges.remove(action);
    } else {
      shortcutChanges[action] = combo;
    }
    changed();
  }

  /// A key of `languages` (language.dart), `null` for the system's. Its own
  /// notifier: changing it rebuilds the whole app, a volume slider must not.
  final language = ValueNotifier<String?>(null);

  double volumeOf(Participant p) =>
      silenced.contains(personKey(p)) ? 0 : volumes[personKey(p)] ?? 1;

  Future<void> load() async {
    final raw = await _secrets.read(_key);
    if (raw == null) return;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      microphone = json['microphone'] as String?;
      camera = json['camera'] as String?;
      speaker = json['speaker'] as String?;
      processing = json['processing'] as bool? ?? true;
      volumes = {
        for (final MapEntry(:key, :value)
            in (json['volumes'] as Map<String, dynamic>? ?? {}).entries)
          key: (value as num).toDouble(),
      };
      silenced = {
        for (final key in json['silenced'] as List<dynamic>? ?? [])
          key as String,
      };
      cues = json['cues'] as bool? ?? true;
      shortcutChanges = {
        for (final MapEntry(:key, :value)
            in (json['shortcuts'] as Map<String, dynamic>? ?? {}).entries)
          // Actions this version doesn't know are dropped.
          ?CallAction.values.asNameMap()[key]: value == null
              ? null
              : KeyCombo.parse(value as String),
      };
      crashReports = json['crash_reports'] as bool? ?? false;
      showPingAndLoss = json['show_ping_and_loss'] as bool? ?? false;
      notifyMessages = json['notify_messages'] as bool? ?? true;
      notifySummons = json['notify_summons'] as bool? ?? true;
      screenSound = json['screen_sound'] as bool? ?? true;
      collapsed = {
        for (final id in json['collapsed'] as List<dynamic>? ?? [])
          id as String,
      };
      language.value = json['language'] as String?;
      notifyListeners();
    } catch (e) {
      debugPrint('ignoring unreadable preferences: $e');
    }
  }

  @override
  void dispose() {
    language.dispose();
    super.dispose();
  }

  /// Saves and tells everyone listening (the call applies the change).
  void changed() {
    notifyListeners();
    unawaited(
      _secrets.write(
        _key,
        jsonEncode({
          'microphone': microphone,
          'camera': camera,
          'speaker': speaker,
          'processing': processing,
          'volumes': volumes,
          'silenced': silenced.toList(),
          'cues': cues,
          'shortcuts': {
            for (final MapEntry(:key, :value) in shortcutChanges.entries)
              key.name: value?.toString(),
          },
          'crash_reports': crashReports,
          'show_ping_and_loss': showPingAndLoss,
          'notify_messages': notifyMessages,
          'notify_summons': notifySummons,
          'screen_sound': screenSound,
          'collapsed': collapsed.toList(),
          'language': language.value,
        }),
      ),
    );
  }
}

final preferencesProvider = Provider<Preferences>((ref) {
  final preferences = Preferences(ref.read(secretsProvider));
  // Reports start once the saved choice is read, and follow it.
  preferences.addListener(
    () => unawaited(reports.crashReports.setEnabled(preferences.crashReports)),
  );
  unawaited(preferences.load());
  ref.onDispose(preferences.dispose);
  return preferences;
});
