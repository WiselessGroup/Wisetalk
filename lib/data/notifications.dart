// System notifications: new chat messages and summons while Wisetalk isn't
// the window in front. A click brings the person to what it was about.

import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import 'language.dart';
import 'linux_notifications.dart';
import 'preferences.dart';

/// Whether [state] means the person is looking at Wisetalk. Only `resumed`
/// does: a window in the background is `inactive` (on GNOME's Wayland a
/// minimized one too, the system doesn't tell), a hidden one `hidden`, an
/// app in the background on a phone `paused`. `null` is before the window
/// first showed, right after the person started the app.
///
/// [launchedInBackground] when the system started Wisetalk without a window
/// for Stay Connected: then nobody is looking until a window shows.
bool isInFront(AppLifecycleState? state, {bool launchedInBackground = false}) =>
    state == null ? !launchedInBackground : state == AppLifecycleState.resumed;

/// The system started Wisetalk for Stay Connected, with no window (Android,
/// `--background`, lib/data/stay_connected.dart).
bool launchedInBackground = false;

/// Whether Wisetalk is the window in front now: notifications only when not.
/// Read from the binding, which follows every change from the start, and
/// never kept by whoever asks: the desktop embedders tell only changes, so a
/// workspace built for a new connection while Wisetalk was in the
/// background thought it was in front until the window was focused and left
/// again (WLK-1).
bool get appInFront => isInFront(
  WidgetsBinding.instance.lifecycleState,
  launchedInBackground: launchedInBackground,
);

/// What a notification leads to when clicked.
sealed class NotificationTarget {
  const NotificationTarget();

  /// Back from a notification's payload; `null` for one this app didn't make.
  static NotificationTarget? parse(String? payload) {
    final at = payload?.indexOf(':') ?? -1;
    if (at < 1 || at == payload!.length - 1) return null;
    final rest = payload.substring(at + 1);
    return switch (payload.substring(0, at)) {
      'chat' => ChatTarget(rest),
      'summon' => SummonTarget.parse(rest),
      _ => null,
    };
  }

  String get payload;
}

/// A channel's chat, to open.
class ChatTarget extends NotificationTarget {
  const ChatTarget(this.channel);

  final String channel;

  @override
  String get payload => 'chat:$channel';
}

/// A channel someone summoned us to, to join.
class SummonTarget extends NotificationTarget {
  const SummonTarget(this.channel, {this.server});

  /// From what follows `summon:` in a payload: the channel, then the server
  /// after a space when there is one.
  factory SummonTarget.parse(String rest) {
    final space = rest.indexOf(' ');
    if (space < 0) return SummonTarget(rest);
    return SummonTarget(
      rest.substring(0, space),
      server: Uri.tryParse(rest.substring(space + 1)),
    );
  }

  final String channel;

  /// Whose channel, when it may not be the current server's.
  final Uri? server;

  @override
  String get payload =>
      server == null ? 'summon:$channel' : 'summon:$channel $server';
}

/// The Linux runner's window (linux/runner/my_application.cc).
const _window = MethodChannel('net.wiseless.wisetalk/window');

class Notifications {
  Notifications(this._preferences);

  final Preferences _preferences;
  final _plugin = FlutterLocalNotificationsPlugin();
  // Linux has its own, for the click to bring the window forward.
  late final _linux = Platform.isLinux ? LinuxNotifications() : null;
  final _clicks = StreamController<NotificationTarget>.broadcast();
  Future<bool>? _ready;
  bool _askedPermission = false;
  int _next = 0;
  NotificationTarget? _waiting;

  /// Where clicked notifications lead.
  Stream<NotificationTarget> get clicks => _clicks.stream;

  /// A click nobody could follow yet: the one that started Wisetalk, or a
  /// summons to another server, waiting for its workspace.
  NotificationTarget? takeWaiting() {
    final target = _waiting;
    _waiting = null;
    return target;
  }

  void wait(NotificationTarget target) => _waiting = target;

  /// In the person's language, read when a notification is made.
  AppLocalizations get _texts => textsFor(_preferences.language.value);

  /// Sets notifications up, and asks for the permission where the system
  /// wants that (Android), up front instead of at the first message: once
  /// there is a window to ask in, which Stay Connected may start without.
  Future<bool> prepare() async {
    final ok = await (_ready ??= _start());
    if (ok && Platform.isAndroid && !_askedPermission && appInFront) {
      _askedPermission = true;
      try {
        await _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.requestNotificationsPermission();
      } catch (e) {
        debugPrint('cannot ask for notifications: $e');
      }
    }
    return ok;
  }

  Future<bool> _start() async {
    try {
      if (_linux case final linux?) {
        linux.clicks.listen(_linuxClicked);
        await linux.start();
        return true;
      }
      final ok = await _plugin.initialize(
        settings: const InitializationSettings(
          windows: WindowsInitializationSettings(
            appName: 'Wisetalk',
            appUserModelId: 'net.wiseless.wisetalk',
            guid: '7e6687f4-2472-45e9-b0e9-3070b787f341',
          ),
          macOS: DarwinInitializationSettings(),
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        ),
        onDidReceiveNotificationResponse: (response) {
          final target = NotificationTarget.parse(response.payload);
          if (target != null) _clicked(target);
        },
      );
      if (Platform.isAndroid) {
        // A tap on a notification while Wisetalk was closed started it.
        final launch = await _plugin.getNotificationAppLaunchDetails();
        if (launch != null && launch.didNotificationLaunchApp) {
          _waiting = NotificationTarget.parse(
            launch.notificationResponse?.payload,
          );
        }
      }
      return ok ?? false;
    } catch (e) {
      // No notification service (a bare window manager, say): carry on.
      debugPrint('notifications unavailable: $e');
      return false;
    }
  }

  /// [caller] summoned us to [channel], named [channelName], on [server];
  /// the same words as the web client's push.
  Future<void> summoned({
    required String caller,
    required String channel,
    required String channelName,
    Uri? server,
  }) {
    final texts = _texts;
    return show(
      title: texts.notificationSummonTitle(caller),
      body: texts.notificationSummonBody(channelName),
      target: SummonTarget(channel, server: server),
    );
  }

  Future<void> show({
    required String title,
    required String body,
    required NotificationTarget target,
  }) async {
    if (!await prepare()) return;
    final texts = _texts;
    try {
      if (_linux case final linux?) {
        await linux.show(
          title: title,
          body: body,
          payload: target.payload,
          action: texts.notificationOpen,
        );
        return;
      }
      // One notification per summons and channel: a second summons to
      // the same channel replaces the first without a second sound.
      final summon = target is SummonTarget;
      await _plugin.show(
        id: summon ? 0 : _next++,
        title: title,
        body: body,
        payload: target.payload,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            'messages',
            texts.notificationChannel,
            importance: Importance.high,
            priority: Priority.high,
            tag: target is SummonTarget ? 'summon:${target.channel}' : null,
            onlyAlertOnce: summon,
          ),
          macOS: const DarwinNotificationDetails(),
        ),
      );
    } catch (e) {
      debugPrint('cannot show a notification: $e');
    }
  }

  void _linuxClicked(LinuxClick click) {
    // Forward first: on Wayland the token is only good for a moment.
    _window.invokeMethod<void>('present', click.token).catchError((Object e) {
      debugPrint('cannot bring the window forward: $e');
    });
    final target = NotificationTarget.parse(click.payload);
    if (target != null) _clicked(target);
  }

  /// Kept for the workspace when none listens yet: a tap that opened the
  /// window of a Wisetalk Stay Connected started without one.
  void _clicked(NotificationTarget target) {
    if (_clicks.hasListener) {
      _clicks.add(target);
    } else {
      _waiting = target;
    }
  }
}

final notificationsProvider = Provider<Notifications>(
  (ref) => Notifications(ref.read(preferencesProvider)),
);
