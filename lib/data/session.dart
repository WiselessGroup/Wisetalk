// The session on the current server: its token, kept in [Secrets], and who
// it belongs to. Signed out (`null`) until someone signs in there.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api.dart';
import 'servers.dart';
import 'unified_push.dart';

class Session {
  const Session({required this.server, required this.me, required this.token});

  final SavedServer server;
  final Me me;
  final String token;

  Api get api => Api(server.origin, token: token);
}

final sessionProvider = AsyncNotifierProvider<SessionNotifier, Session?>(
  SessionNotifier.new,
);

class SessionNotifier extends AsyncNotifier<Session?> {
  @override
  Future<Session?> build() async {
    // Only switching servers starts over, not renaming one.
    final origin = await ref.watch(
      serversProvider.selectAsync((s) => s.current),
    );
    if (origin == null) return null;
    final server = (await ref.read(serversProvider.future)).currentServer;
    final token = await ref.read(secretsProvider).read(tokenKey(origin));
    if (server == null || token == null) return null;
    try {
      final me = await Api(origin, token: token).me();
      return Session(server: server, me: me, token: token);
    } on ApiException catch (error) {
      if (!error.unauthorized && error.status != 403) rethrow;
      // Signed out elsewhere, expired, or banned: sign in again.
      await ref.read(secretsProvider).delete(tokenKey(origin));
      return null;
    }
  }

  /// Keeps a new session on the current server.
  Future<void> start(SavedServer server, SignedIn signedIn) async {
    await ref
        .read(secretsProvider)
        .write(tokenKey(server.origin), signedIn.token);
    await ref
        .read(serversProvider.notifier)
        .remember(server.origin, signedIn.me.displayName);
    state = AsyncData(
      Session(server: server, me: signedIn.me, token: signedIn.token),
    );
  }

  Future<void> signOut() async {
    final session = state.value;
    if (session == null) return;
    // While the token still works to take the push endpoint back.
    await unifiedPushes.forget(session.server.origin);
    try {
      await session.api.signOut();
    } on ApiException {
      // Gone from the server already, or unreachable: forget it here anyway.
    }
    await ref.read(secretsProvider).delete(tokenKey(session.server.origin));
    state = const AsyncData(null);
  }
}
