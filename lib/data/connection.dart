// The live connection to the current server while signed in: the gateway,
// and voice and chats on top of it. Made when a session starts, closed when
// it ends.

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'chat.dart';
import 'device.dart';
import 'gateway.dart';
import 'global_shortcuts.dart';
import 'preferences.dart';
import 'servers.dart';
import 'session.dart';
import 'trust.dart';
import 'voice.dart';

class Connection {
  const Connection(this.gateway, this.voice, this.chats);

  final Gateway gateway;
  final Voice voice;
  final Chats chats;
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
  final trust = KeyWatch(
    ref.read(secretsProvider),
    session.server.origin,
    session.api.server().then((info) => info.guestsOpen),
  );
  final voice = Voice(gateway, ref.read(preferencesProvider), trust: trust);
  final shortcuts = GlobalShortcuts(voice, ref.read(preferencesProvider));
  final chats = Chats(gateway, device, account: session.me.id, trust: trust);
  ref.onDispose(() {
    chats.dispose();
    shortcuts.dispose();
    voice.dispose();
    trust.dispose();
    gateway.dispose();
  });
  unawaited(gateway.connect());
  return Connection(gateway, voice, chats);
});
