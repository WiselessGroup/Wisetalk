import 'dart:io';

import 'package:dbus/dbus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wisetalk/data/linux_notifications.dart';

/// A notification server like GNOME's: markup in bodies, and a token sent
/// to the notification's sender right before its click.
class _Server extends DBusObject {
  _Server() : super(DBusObjectPath('/org/freedesktop/Notifications'));

  final List<List<DBusValue>> notified = [];
  String? sender;

  @override
  Future<DBusMethodResponse> handleMethodCall(DBusMethodCall call) async {
    switch (call.name) {
      case 'GetCapabilities':
        return DBusMethodSuccessResponse([
          DBusArray.string(['actions', 'body', 'body-markup']),
        ]);
      case 'Notify':
        notified.add(call.values);
        sender = call.sender;
        return DBusMethodSuccessResponse([DBusUint32(40 + notified.length)]);
    }
    return DBusMethodErrorResponse.unknownMethod();
  }

  Future<void> signal(String name, int id, DBusValue value) =>
      client!.emitSignal(
        destination: sender,
        path: path,
        interface: 'org.freedesktop.Notifications',
        name: name,
        values: [DBusUint32(id), value],
      );
}

void main() {
  late Directory dir;
  late DBusServer bus;
  late DBusClient serverClient;
  late _Server server;
  late LinuxNotifications notifications;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('wisetalk-dbus');
    bus = DBusServer();
    final address = await bus.listenAddress(DBusAddress.unix(dir: dir));
    serverClient = DBusClient(address);
    server = _Server();
    await serverClient.registerObject(server);
    await serverClient.requestName('org.freedesktop.Notifications');
    notifications = LinuxNotifications(
      client: DBusClient(address),
      icon: '/app/logo.png',
    );
    await notifications.start();
  });

  tearDown(() async {
    await notifications.close();
    await serverClient.close();
    await bus.close();
    await dir.delete(recursive: true);
  });

  test('names the desktop entry and escapes the body', () async {
    await notifications.show(
      title: 'Ann in <General>',
      body: 'a < b & c',
      payload: 'chat:1',
    );
    final values = server.notified.single;
    expect(values[0].asString(), 'Wisetalk');
    expect(values[2].asString(), '/app/logo.png');
    expect(values[3].asString(), 'Ann in <General>');
    expect(values[4].asString(), 'a &lt; b &amp; c');
    expect(values[5].asStringArray(), ['default', 'Open']);
    final hints = values[6].asStringVariantDict();
    expect(hints['desktop-entry']?.asString(), 'net.wiseless.wisetalk');
    expect(hints['category']?.asString(), 'im.received');
  });

  test('a click comes with its activation token', () async {
    await notifications.show(title: 'A', body: 'one', payload: 'chat:1');
    await notifications.show(title: 'B', body: 'two', payload: 'summon:2');
    final click = notifications.clicks.first;
    await server.signal('ActivationToken', 42, const DBusString('token-42'));
    await server.signal('ActionInvoked', 42, const DBusString('default'));
    expect(await click, (payload: 'summon:2', token: 'token-42'));

    // A server that sends no token (dunst, say).
    final next = notifications.clicks.first;
    await server.signal('ActionInvoked', 41, const DBusString('default'));
    expect(await next, (payload: 'chat:1', token: null));
  });

  test('closed and unknown notifications lead nowhere', () async {
    await notifications.show(title: 'A', body: 'one', payload: 'chat:1');
    final clicks = <LinuxClick>[];
    final subscription = notifications.clicks.listen(clicks.add);
    await server.signal('NotificationClosed', 41, const DBusUint32(2));
    await server.signal('ActionInvoked', 41, const DBusString('default'));
    // Another app's notification.
    await server.signal('ActionInvoked', 7, const DBusString('default'));
    await pumpEventQueue();
    expect(clicks, isEmpty);
    await subscription.cancel();
  });
}
