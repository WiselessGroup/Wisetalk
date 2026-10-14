// Where the app picks its server. One server is one community; this list
// is the servers you've used, to go back to or forget. The first run shows
// only the address field. A server's web page can fill it in too, through
// a wisetalk: link (see data/links.dart).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/address.dart';
import '../data/api.dart';
import '../data/links.dart';
import '../data/servers.dart';
import '../src/rust/api/text.dart';
import '../theme.dart';
import 'common.dart';

class ServersScreen extends ConsumerStatefulWidget {
  const ServersScreen({super.key});

  @override
  ConsumerState<ServersScreen> createState() => _ServersScreenState();
}

class _ServersScreenState extends ConsumerState<ServersScreen> {
  final _address = TextEditingController();
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _address.dispose();
    super.dispose();
  }

  /// Checks that the address is a Wisetalk server this app can talk to,
  /// then keeps it and goes on to sign in.
  Future<void> _connect() async {
    final origin = parseServerAddress(_address.text);
    if (origin == null) {
      setState(
        () => _error = 'Type the address of a server, like talk.example.com.',
      );
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final info = await Api(origin).server();
      final ours = protocolVersion();
      if (info.protocol != ours) {
        throw ApiException(
          0,
          info.protocol > ours
              ? 'This server is newer than this app. Update Wisetalk to join it.'
              : 'This server runs an older Wisetalk${info.version.isEmpty ? '' : ' (${info.version})'}. Ask its admins to update it.',
        );
      }
      await ref
          .read(serversProvider.notifier)
          .add(
            SavedServer(
              origin: origin,
              name: info.branding.community ?? displayAddress(origin),
            ),
          );
      if (mounted) context.go('/');
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _open(SavedServer server) async {
    await ref.read(serversProvider.notifier).select(server.origin);
    if (mounted) context.go('/');
  }

  Future<void> _remove(SavedServer server) async {
    final sure = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove ${server.name}?'),
        content: const Text(
          'This device signs out of it and forgets it. You can add it again with its address.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (sure == true) {
      await ref.read(serversProvider.notifier).remove(server.origin);
    }
  }

  @override
  Widget build(BuildContext context) {
    final servers = ref.watch(serversProvider).value;
    final saved = servers?.list ?? const <SavedServer>[];
    // A link brought a server that didn't work out: show it and why.
    final pending = ref.watch(pendingAddressProvider);
    if (pending != null) {
      _address.text = pending.address;
      _error = pending.error;
      Future.microtask(
        () => ref.read(pendingAddressProvider.notifier).set(null),
      );
    }
    final palette = context.palette;

    final form = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _address,
          autofocus: saved.isEmpty,
          enabled: !_busy,
          keyboardType: TextInputType.url,
          autocorrect: false,
          textInputAction: TextInputAction.go,
          onSubmitted: (_) => _connect(),
          decoration: const InputDecoration(hintText: 'talk.example.com'),
        ),
        const SizedBox(height: 8),
        Text(
          'Ask whoever runs your community for its address.',
          style: TextStyle(fontSize: 13, color: palette.muted),
        ),
        if (_error != null) ...[const SizedBox(height: 12), ErrorBox(_error!)],
        const SizedBox(height: 16),
        FilledButton(
          onPressed: _busy ? null : _connect,
          child: Text(_busy ? 'Connecting…' : 'Connect'),
        ),
      ],
    );

    return CenteredCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Masthead(
            subtitle: saved.isEmpty
                ? 'Which server is your community on?'
                : null,
          ),
          const SizedBox(height: 24),
          if (saved.isNotEmpty) ...[
            _Header('Your Servers'),
            _ServerList(
              servers: saved,
              current: servers?.current,
              onOpen: _open,
              onRemove: _remove,
            ),
            const SizedBox(height: 24),
            _Header('Add a Server'),
          ],
          form,
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: context.palette.muted,
      ),
    ),
  );
}

/// Saved servers as an inset grouped list: tap to go there, ⋯ to remove.
class _ServerList extends StatelessWidget {
  const _ServerList({
    required this.servers,
    required this.current,
    required this.onOpen,
    required this.onRemove,
  });

  final List<SavedServer> servers;
  final Uri? current;
  final void Function(SavedServer) onOpen;
  final void Function(SavedServer) onRemove;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Material(
        color: palette.cell,
        child: Column(
          children: [
            for (final (i, server) in servers.indexed) ...[
              if (i > 0)
                Divider(height: 1, indent: 60, color: palette.separator),
              ListTile(
                minTileHeight: 56,
                onTap: () => onOpen(server),
                leading: CircleAvatar(
                  radius: 18,
                  backgroundColor: palette.accent.withValues(alpha: 0.2),
                  foregroundColor: palette.accent,
                  child: Text(
                    server.name.characters.first.toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                title: Text(
                  server.name,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: palette.text,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  [
                    displayAddress(server.origin),
                    if (server.user != null) server.user!,
                  ].join(' · '),
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: palette.muted, fontSize: 13),
                ),
                trailing: PopupMenuButton<void>(
                  tooltip: 'More',
                  icon: Icon(Icons.more_horiz, color: palette.muted),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      onTap: () => onRemove(server),
                      child: Text(
                        'Remove Server',
                        style: TextStyle(color: palette.error),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
