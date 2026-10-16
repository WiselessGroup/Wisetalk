// Where the app picks its server. One server is one community; this list
// is the servers you've used, to go back to or forget. The first run shows
// only the address field. A server's web page can fill it in too, through
// a wisetalk: link (see data/links.dart). Adding one more, once there are
// some, is a sheet of its own.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/address.dart';
import '../data/api.dart';
import '../data/links.dart';
import '../data/servers.dart';
import '../l10n/app_localizations.dart';
import '../src/rust/api/text.dart';
import '../theme.dart';
import 'common.dart';
import 'settings_sheet.dart';

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

  /// The first run's form: on to signing in once the server checks out.
  Future<void> _connect() async {
    final texts = AppLocalizations.of(context);
    setState(() {
      _busy = true;
      _error = null;
    });
    final error = await _addServer(ref, texts, _address.text);
    if (!mounted) return;
    if (error == null) {
      context.go('/');
    } else {
      setState(() {
        _busy = false;
        _error = error;
      });
    }
  }

  /// Another server, besides those saved, in a sheet of its own.
  Future<void> _addAnother({String address = '', String? error}) async {
    final added = await showSettingsSheet<bool>(
      context,
      builder: (_) => _AddServerSheet(address: address, error: error),
    );
    if (added == true && mounted) context.go('/');
  }

  Future<void> _open(SavedServer server) async {
    await ref.read(serversProvider.notifier).select(server.origin);
    if (mounted) context.go('/');
  }

  Future<void> _remove(SavedServer server) async {
    final texts = AppLocalizations.of(context);
    final sure = await confirm(
      context,
      title: texts.serversRemoveTitle(server.name),
      message: texts.serversRemoveMessage,
      action: texts.serversRemove,
    );
    if (sure) {
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
      Future.microtask(
        () => ref.read(pendingAddressProvider.notifier).set(null),
      );
      if (saved.isEmpty) {
        _address.text = pending.address;
        _error = pending.error;
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _addAnother(address: pending.address, error: pending.error);
          }
        });
      }
    }
    final palette = context.palette;
    final texts = AppLocalizations.of(context);

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
          // An example, the same in every language.
          decoration: const InputDecoration(hintText: 'talk.example.com'),
        ),
        const SizedBox(height: 8),
        Text(
          texts.serversAddressHelp,
          style: TextStyle(fontSize: 13, color: palette.muted),
        ),
        if (_error != null) ...[const SizedBox(height: 12), ErrorBox(_error!)],
        const SizedBox(height: 16),
        FilledButton(
          onPressed: _busy ? null : _connect,
          child: Text(_busy ? texts.serversConnecting : texts.serversConnect),
        ),
      ],
    );

    return CenteredCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Masthead(subtitle: saved.isEmpty ? texts.serversWhich : null),
          const SizedBox(height: 24),
          if (saved.isNotEmpty) ...[
            _Header(texts.serversYours),
            _ServerList(
              servers: saved,
              current: servers?.current,
              onOpen: _open,
              onRemove: _remove,
            ),
            const SizedBox(height: 16),
            SettingsGroup(
              children: [
                ButtonRow(
                  label: texts.serversAddMenu,
                  onTap: () => _addAnother(),
                ),
              ],
            ),
          ] else
            form,
        ],
      ),
    );
  }
}

/// Checks that [text] is the address of a Wisetalk server this app can
/// talk to, then keeps it as the one to go to. Null when that worked;
/// otherwise what went wrong, in [texts].
Future<String?> _addServer(
  WidgetRef ref,
  AppLocalizations texts,
  String text,
) async {
  final origin = parseServerAddress(text);
  if (origin == null) return texts.serversBadAddress;
  try {
    final info = await Api(origin).server();
    final ours = protocolVersion();
    if (info.protocol != ours) {
      if (info.protocol > ours) return texts.serversTooNew;
      return info.version.isEmpty
          ? texts.serversTooOld
          : texts.serversTooOldVersion(info.version);
    }
    await ref
        .read(serversProvider.notifier)
        .add(
          SavedServer(
            origin: origin,
            name: info.branding.community ?? displayAddress(origin),
          ),
        );
    return null;
  } on ApiException catch (e) {
    return e.message;
  }
}

/// Adding a server when there are some already. True once it's added.
class _AddServerSheet extends ConsumerStatefulWidget {
  const _AddServerSheet({required this.address, this.error});

  /// Filled in already, by a link that didn't work out.
  final String address;
  final String? error;

  @override
  ConsumerState<_AddServerSheet> createState() => _AddServerSheetState();
}

class _AddServerSheetState extends ConsumerState<_AddServerSheet> {
  late final _address = TextEditingController(text: widget.address)
    ..addListener(() => setState(() {}));
  late String? _error = widget.error;

  @override
  void dispose() {
    _address.dispose();
    super.dispose();
  }

  Future<void> _connect() async {
    final texts = AppLocalizations.of(context);
    setState(() => _error = null);
    final error = await _addServer(ref, texts, _address.text);
    if (!mounted) return;
    if (error == null) {
      Navigator.pop(context, true);
    } else {
      setState(() => _error = error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final typed = _address.text.trim();
    final texts = AppLocalizations.of(context);
    return SettingsSheet(
      title: texts.serversAddTitle,
      action: texts.serversConnect,
      dirty: typed.isNotEmpty && typed != widget.address,
      onAction: typed.isEmpty ? null : _connect,
      children: [
        SettingsGroup(
          footer: texts.serversAddressHelp,
          error: _error,
          children: [
            TextFieldRow(
              label: texts.serversAddress,
              controller: _address,
              hint: 'talk.example.com',
              keyboardType: TextInputType.url,
              autocorrect: false,
              autofocus: true,
            ),
          ],
        ),
      ],
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
    final texts = AppLocalizations.of(context);
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
                  tooltip: texts.serversMore,
                  icon: Icon(Icons.more_horiz, color: palette.muted),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      onTap: () => onRemove(server),
                      child: Text(
                        texts.serversRemoveServer,
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
