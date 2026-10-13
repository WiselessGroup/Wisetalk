// Where the app is: picking a server, signing in, or signed in. The state
// decides; screens only ask to go to '/' and get sent to the right place.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'data/servers.dart';
import 'data/session.dart';
import 'theme.dart';
import 'ui/home_screen.dart';
import 'ui/servers_screen.dart';
import 'ui/sign_in_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final changed = ValueNotifier(0);
  ref.listen(serversProvider, (_, _) => changed.value++);
  ref.listen(sessionProvider, (_, _) => changed.value++);
  ref.onDispose(changed.dispose);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: changed,
    redirect: (context, state) {
      final servers = ref.read(serversProvider);
      final session = ref.read(sessionProvider);
      final here = state.matchedLocation;
      if (!servers.hasValue ||
          (session.isLoading && !session.hasValue && !session.hasError)) {
        return here == '/' ? null : '/';
      }
      final String target;
      if (servers.value!.current == null) {
        target = '/servers';
      } else if (session.value != null) {
        target = '/home';
      } else {
        target = '/sign-in';
      }
      // The server list stays reachable from anywhere.
      if (here == '/servers' || here == target) return null;
      return target;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const _Launch()),
      GoRoute(
        path: '/servers',
        builder: (context, state) => const ServersScreen(),
      ),
      GoRoute(
        path: '/sign-in',
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    ],
  );
});

/// While the saved servers and the session load: the background only, so
/// a fast start doesn't flash anything.
class _Launch extends StatelessWidget {
  const _Launch();

  @override
  Widget build(BuildContext context) => ColoredBox(color: context.palette.bg);
}
