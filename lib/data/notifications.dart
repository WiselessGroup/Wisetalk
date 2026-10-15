// System notifications: new chat messages and summons while Wisetalk isn't
// the window in front. A click brings the person to what it was about.

import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Whether [state] means the person is looking at Wisetalk. Only `resumed`
/// does: a window in the background is `inactive` (on GNOME's Wayland a
/// minimized one too, the system doesn't tell), a hidden one `hidden`, an
/// app in the background on a phone `paused`. `null` is before the window
/// first showed, right after the person started the app.
bool isInFront(AppLifecycleState? state) =>
    state == null || state == AppLifecycleState.resumed;

/// Whether Wisetalk is the window in front now: notifications only when not.
/// Read from the binding, which follows every change from the start, and
/// never kept by whoever asks: the desktop embedders tell only changes, so a
/// workspace built for a new connection while Wisetalk was in the
/// background thought it was in front until the window was focused and left
/// again (WLK-1).
bool get appInFront => isInFront(WidgetsBinding.instance.lifecycleState);

/// What a notification leads to when clicked.
sealed class NotificationTarget {
  const NotificationTarget();

  /// Back from a notification's payload; `null` for one this app didn't make.
  static NotificationTarget? parse(String? payload) {
    final at = payload?.indexOf(':') ?? -1;
    if (at < 1 || at == payload!.length - 1) return null;
    final channel = payload.substring(at + 1);
    return switch (payload.substring(0, at)) {
      'chat' => ChatTarget(channel),
      'summon' => SummonTarget(channel),
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
  const SummonTarget(this.channel);

  final String channel;

  @override
  String get payload => 'summon:$channel';
}

class Notifications {
  final _plugin = FlutterLocalNotificationsPlugin();
  final _clicks = StreamController<NotificationTarget>.broadcast();
  Future<bool>? _ready;
  int _next = 0;

  /// Where clicked notifications lead.
  Stream<NotificationTarget> get clicks => _clicks.stream;

  /// Sets notifications up, and asks for the permission where the system
  /// wants that (Android), up front instead of at the first message.
  Future<bool> prepare() => _ready ??= _start();

  Future<bool> _start() async {
    try {
      final ok = await _plugin.initialize(
        settings: const InitializationSettings(
          linux: LinuxInitializationSettings(defaultActionName: 'Open'),
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
          if (target != null) _clicks.add(target);
        },
      );
      if (Platform.isAndroid) {
        await _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.requestNotificationsPermission();
      }
      return ok ?? false;
    } catch (e) {
      // No notification service (a bare window manager, say): carry on.
      debugPrint('notifications unavailable: $e');
      return false;
    }
  }

  Future<void> show({
    required String title,
    required String body,
    required NotificationTarget target,
  }) async {
    if (!await prepare()) return;
    try {
      await _plugin.show(
        id: _next++,
        title: title,
        body: body,
        payload: target.payload,
        notificationDetails: const NotificationDetails(
          linux: LinuxNotificationDetails(
            category: LinuxNotificationCategory.imReceived,
          ),
          android: AndroidNotificationDetails(
            'messages',
            'Messages and summons',
            importance: Importance.high,
            priority: Priority.high,
          ),
          macOS: DarwinNotificationDetails(),
        ),
      );
    } catch (e) {
      debugPrint('cannot show a notification: $e');
    }
  }
}

final notificationsProvider = Provider<Notifications>((ref) => Notifications());
