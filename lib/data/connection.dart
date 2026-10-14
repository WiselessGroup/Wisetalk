// The live connection to the current server while signed in: the gateway
// and voice on top of it. Made when a session starts, closed when it ends.

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'device.dart';
import 'gateway.dart';
import 'servers.dart';
import 'session.dart';
import 'voice.dart';

class Connection {
  const Connection(this.gateway, this.voice);

  final Gateway gateway;
  final Voice voice;
}

final connectionProvider = FutureProvider<Connection?>((ref) async {
  final session = await ref.watch(sessionProvider.future);
  if (session == null) return null;
  final device = await localDevice(
    ref.read(secretsProvider),
    session.server.origin,
    guest: session.me.isGuest,
  );
  final gateway = Gateway(session, device);
  final voice = Voice(gateway);
  ref.onDispose(() {
    voice.dispose();
    gateway.dispose();
  });
  unawaited(gateway.connect());
  return Connection(gateway, voice);
});
