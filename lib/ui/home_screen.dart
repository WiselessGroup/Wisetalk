// Signed in. Channels, calls and chats come next; for now this says who is
// signed in where, and offers the ways out.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/address.dart';
import '../data/servers.dart';
import '../data/session.dart';
import '../theme.dart';
import 'common.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final session = ref.watch(sessionProvider).value;
    if (session == null) return const SizedBox.shrink();
    final me = session.me;
    return CenteredCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: palette.accent.withValues(alpha: 0.2),
            foregroundColor: palette.accent,
            child: Text(
              me.displayName.characters.first.toUpperCase(),
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            me.displayName,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: palette.text,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            [
              if (me.isGuest) 'Guest' else '@${me.username}',
              'on ${session.server.name}',
            ].join(' · '),
            textAlign: TextAlign.center,
            style: TextStyle(color: palette.muted),
          ),
          if (session.server.name != displayAddress(session.server.origin))
            Text(
              displayAddress(session.server.origin),
              textAlign: TextAlign.center,
              style: TextStyle(color: palette.tertiary, fontSize: 13),
            ),
          const SizedBox(height: 24),
          Text(
            'Channels, calls and chats come in the next version of the app.',
            textAlign: TextAlign.center,
            style: TextStyle(color: palette.muted, fontSize: 13),
          ),
          const SizedBox(height: 20),
          OutlinedButton(
            onPressed: () async {
              await ref.read(serversProvider.notifier).leave();
              if (context.mounted) context.go('/servers');
            },
            child: const Text('Change Server'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => ref.read(sessionProvider.notifier).signOut(),
            child: Text('Sign Out', style: TextStyle(color: palette.error)),
          ),
        ],
      ),
    );
  }
}
