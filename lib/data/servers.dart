// The servers this app knows: added by hand, remembered with who signed in
// there last. One is current at a time; one server is one community, and
// there is no sidebar of servers. Each server has its own session token and
// device key, and removing a server forgets both.

import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'secrets.dart';

final secretsProvider = Provider<Secrets>((ref) => SystemSecrets());

String tokenKey(Uri origin) => 'token:$origin';
String deviceKey(Uri origin) => 'device:$origin';

/// The guest passport of a server, see [SignedIn.passport]; outlives the
/// session token, goes with the server.
String passportKey(Uri origin) => 'passport:$origin';
const serversKey = 'servers';
const currentServerKey = 'current-server';

class SavedServer {
  const SavedServer({required this.origin, required this.name, this.user});

  factory SavedServer.fromJson(Map<String, dynamic> json) => SavedServer(
    origin: Uri.parse(json['origin'] as String),
    name: json['name'] as String,
    user: json['user'] as String?,
  );

  final Uri origin;

  /// The community's name, or the address when the server doesn't say.
  final String name;

  /// Who signed in here last.
  final String? user;

  SavedServer copyWith({String? name, String? user}) => SavedServer(
    origin: origin,
    name: name ?? this.name,
    user: user ?? this.user,
  );

  Map<String, dynamic> toJson() => {
    'origin': origin.toString(),
    'name': name,
    if (user != null) 'user': user,
  };
}

class Servers {
  const Servers(this.list, this.current);

  final List<SavedServer> list;
  final Uri? current;

  SavedServer? get currentServer {
    for (final server in list) {
      if (server.origin == current) return server;
    }
    return null;
  }
}

final serversProvider = AsyncNotifierProvider<ServersNotifier, Servers>(
  ServersNotifier.new,
);

class ServersNotifier extends AsyncNotifier<Servers> {
  Secrets get _secrets => ref.read(secretsProvider);

  @override
  Future<Servers> build() async {
    final list = <SavedServer>[];
    try {
      final raw = await _secrets.read(serversKey);
      if (raw != null) {
        for (final entry in jsonDecode(raw) as List<dynamic>) {
          list.add(SavedServer.fromJson(entry as Map<String, dynamic>));
        }
      }
    } on FormatException {
      // Unreadable: start over with an empty list.
    }
    final current = await _secrets.read(currentServerKey);
    final origin = current == null ? null : Uri.tryParse(current);
    return Servers(list, list.any((s) => s.origin == origin) ? origin : null);
  }

  Future<void> _save(Servers servers) async {
    state = AsyncData(servers);
    await _secrets.write(
      serversKey,
      jsonEncode(servers.list.map((s) => s.toJson()).toList()),
    );
    if (servers.current == null) {
      await _secrets.delete(currentServerKey);
    } else {
      await _secrets.write(currentServerKey, servers.current.toString());
    }
  }

  Future<Servers> get _now async => state.value ?? await future;

  /// Adds a server, or updates one with the same address, and makes it current.
  Future<void> add(SavedServer server) async {
    final now = await _now;
    final list = [
      for (final s in now.list)
        if (s.origin == server.origin)
          server.copyWith(user: server.user ?? s.user)
        else
          s,
      if (!now.list.any((s) => s.origin == server.origin)) server,
    ];
    await _save(Servers(list, server.origin));
  }

  Future<void> select(Uri origin) async {
    final now = await _now;
    await _save(Servers(now.list, origin));
  }

  /// Back to the list, keeping every session.
  Future<void> leave() async {
    final now = await _now;
    await _save(Servers(now.list, null));
  }

  /// Notes who signed in on a server.
  Future<void> remember(Uri origin, String user) async {
    final now = await _now;
    await _save(
      Servers([
        for (final s in now.list)
          s.origin == origin ? s.copyWith(user: user) : s,
      ], now.current),
    );
  }

  /// Forgets a server with its session token, device key and guest passport.
  Future<void> remove(Uri origin) async {
    final now = await _now;
    await _secrets.delete(tokenKey(origin));
    await _secrets.delete(deviceKey(origin));
    await _secrets.delete(passportKey(origin));
    await _save(
      Servers([
        for (final s in now.list)
          if (s.origin != origin) s,
      ], now.current == origin ? null : now.current),
    );
  }
}
