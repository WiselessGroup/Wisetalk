// System notifications on Linux, straight over D-Bus (the freedesktop
// Desktop Notifications spec) rather than through flutter_local_notifications.
// Clicking one has to bring the window forward, and on Wayland a window can
// come forward only with the activation token the notification server sends
// along with the click; GNOME sends it only to the connection that sent the
// notification, which the plugin keeps to itself and ignores the token on.
// Its hint classes aren't exported either, so it couldn't name the desktop
// entry.

import 'dart:async';
import 'dart:io';

import 'package:dbus/dbus.dart';

import 'desktop_entry.dart';

const _name = 'org.freedesktop.Notifications';
const _interface = 'org.freedesktop.Notifications';
final _path = DBusObjectPath('/org/freedesktop/Notifications');

/// A click on a notification: what it was about, and the token that lets
/// the window come forward (`null` when the server sends none).
typedef LinuxClick = ({String payload, String? token});

class LinuxNotifications {
  LinuxNotifications({DBusClient? client, String? icon})
    : _client = client ?? DBusClient.session(),
      _icon = icon ?? _bundledIcon();

  final DBusClient _client;
  final String _icon;
  late final _server = DBusRemoteObject(_client, name: _name, path: _path);
  final _clicks = StreamController<LinuxClick>.broadcast();
  StreamSubscription<DBusSignal>? _signals;
  bool _markup = false;

  /// Payloads of the notifications shown, by the server's id.
  final Map<int, String> _shown = {};

  /// Tokens that came before their click, by notification id.
  final Map<int, String> _tokens = {};

  Stream<LinuxClick> get clicks => _clicks.stream;

  /// Listens to the notification server; throws when there's none.
  Future<void> start() async {
    // One stream for all of the server's signals, so they arrive in the
    // order sent: the token comes right before its click.
    _signals ??= DBusSignalStream(
      _client,
      sender: _name,
      interface: _interface,
      path: _path,
    ).listen(_signal);
    final reply = await _server.callMethod(
      _interface,
      'GetCapabilities',
      const [],
      replySignature: DBusSignature('as'),
    );
    _markup = reply.values.first.asStringArray().contains('body-markup');
  }

  Future<void> show({
    required String title,
    required String body,
    required String payload,
  }) async {
    final reply = await _server.callMethod(_interface, 'Notify', [
      const DBusString('Wisetalk'),
      const DBusUint32(0),
      DBusString(_icon),
      DBusString(title),
      DBusString(_markup ? _escape(body) : body),
      // The default action is the click on the notification itself.
      DBusArray.string(const ['default', 'Open']),
      DBusDict.stringVariant({
        'category': const DBusString('im.received'),
        // Which app it is when no window tells (none yet, or none at all
        // in the tray, WLK-9): its name, icon and notification settings.
        'desktop-entry': DBusString(desktopEntryId),
      }),
      // The server's usual time.
      const DBusInt32(-1),
    ], replySignature: DBusSignature('u'));
    _shown[reply.values.first.asUint32()] = payload;
  }

  void _signal(DBusSignal signal) {
    final values = signal.values;
    if (values.length != 2 || values.first is! DBusUint32) return;
    final id = values.first.asUint32();
    switch (signal.name) {
      case 'ActivationToken' when _shown.containsKey(id):
        _tokens[id] = values.last.asString();
      case 'ActionInvoked' when values.last.asString() == 'default':
        final payload = _shown[id];
        if (payload != null) {
          _clicks.add((payload: payload, token: _tokens.remove(id)));
        }
      case 'NotificationClosed':
        _shown.remove(id);
        _tokens.remove(id);
    }
  }

  Future<void> close() async {
    await _signals?.cancel();
    await _clicks.close();
    await _client.close();
  }
}

/// The logo inside the app's bundle, for servers that show no desktop
/// entry's icon (GNOME and KDE take the entry's).
String _bundledIcon() {
  final logo = File(
    '${File(Platform.resolvedExecutable).parent.path}'
    '/data/flutter_assets/assets/logo.png',
  );
  return logo.existsSync() ? logo.path : '';
}

/// [text] as plain text in a body the server reads as markup.
String _escape(String text) => text
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;');
