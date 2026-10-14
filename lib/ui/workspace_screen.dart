// Signed in: the channel list in a floating sidebar, the call beside it.
// The same layout as the web client, without video, chat and settings yet.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/address.dart';
import '../data/connection.dart';
import '../data/gateway.dart';
import '../data/protocol.dart';
import '../data/servers.dart';
import '../data/session.dart';
import '../data/voice.dart';
import '../theme.dart';

class WorkspaceScreen extends ConsumerWidget {
  const WorkspaceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final state = ref.watch(connectionProvider);
    // While a new connection starts, or when it failed, the previous value
    // is the old one, already closed: never show that.
    final connection = state.isLoading || state.hasError ? null : state.value;
    final session = ref.watch(sessionProvider).value;
    if (connection == null || session == null) {
      return Scaffold(backgroundColor: palette.window);
    }
    // A new connection gets a new state, listening to it from the start.
    return _Workspace(
      key: ObjectKey(connection),
      connection: connection,
      session: session,
    );
  }
}

class _Workspace extends ConsumerStatefulWidget {
  const _Workspace({
    super.key,
    required this.connection,
    required this.session,
  });

  final Connection connection;
  final Session session;

  @override
  ConsumerState<_Workspace> createState() => _WorkspaceState();
}

class _WorkspaceState extends ConsumerState<_Workspace> {
  Gateway get _gateway => widget.connection.gateway;
  Voice get _voice => widget.connection.voice;
  late final Listenable _changes = Listenable.merge([_gateway, _voice]);
  String? _shownError;

  @override
  void initState() {
    super.initState();
    _voice.addListener(_voiceChanged);
  }

  @override
  void dispose() {
    _voice.removeListener(_voiceChanged);
    super.dispose();
  }

  /// Errors show once as a toast; the take-over question as a dialog.
  void _voiceChanged() {
    final error = _voice.error;
    if (error != null && error != _shownError && mounted) {
      _shownError = error;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
    }
    final asked = _voice.elsewhere;
    if (asked != null && mounted) {
      _voice.elsewhere = null;
      _askTakeOver(asked.$1, asked.$2);
    }
  }

  Future<void> _askTakeOver(String here, String there) async {
    final hereName = _gateway.channel(here)?.channel.name ?? 'this channel';
    final thereName =
        _gateway.channel(there)?.channel.name ?? 'another channel';
    final yes = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Join from This Device?'),
        content: Text(
          "You're in $thereName on another device or tab. Joining $hereName here takes you out of the call there.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Join Here'),
          ),
        ],
      ),
    );
    if (yes == true) {
      _voice.elsewhere = (here, there);
      _voice.takeOver();
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Scaffold(
      backgroundColor: palette.window,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _changes,
          builder: (context, _) => Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: _Sidebar(
                  gateway: _gateway,
                  voice: _voice,
                  session: widget.session,
                ),
              ),
              Expanded(
                child: _CallArea(gateway: _gateway, voice: _voice),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Sidebar extends ConsumerWidget {
  const _Sidebar({
    required this.gateway,
    required this.voice,
    required this.session,
  });

  final Gateway gateway;
  final Voice voice;
  final Session session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final loose = gateway.channels
        .where((v) => v.channel.space == null)
        .toList();
    final spaces = [...gateway.spaces]
      ..sort((a, b) => a.position.compareTo(b.position));
    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: palette.sidebar,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: palette.separator, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(7),
                  child: Image.asset('assets/logo.png', width: 26, height: 26),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    session.server.name,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: palette.text,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (gateway.status != GatewayStatus.ready)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                gateway.ended ??
                    (gateway.status == GatewayStatus.offline
                        ? 'Offline, reconnecting…'
                        : 'Connecting…'),
                style: TextStyle(color: palette.muted, fontSize: 13),
              ),
            ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              children: [
                for (final view in loose)
                  _ChannelRow(view: view, gateway: gateway, voice: voice),
                for (final space in spaces) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 14, 10, 4),
                    child: Text(
                      space.name,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: palette.muted,
                      ),
                    ),
                  ),
                  for (final view in gateway.channels.where(
                    (v) => v.channel.space == space.id,
                  ))
                    _ChannelRow(view: view, gateway: gateway, voice: voice),
                ],
              ],
            ),
          ),
          Divider(height: 1, color: palette.separator),
          ListTile(
            dense: true,
            leading: _Avatar(name: session.me.displayName, size: 30),
            title: Text(
              session.me.displayName,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: palette.text,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              displayAddress(session.server.origin),
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: palette.muted, fontSize: 12),
            ),
            trailing: PopupMenuButton<void>(
              tooltip: 'More',
              icon: Icon(Icons.more_horiz, color: palette.muted),
              itemBuilder: (context) => [
                PopupMenuItem(
                  onTap: () async {
                    voice.leave();
                    await ref.read(serversProvider.notifier).leave();
                    if (context.mounted) context.go('/servers');
                  },
                  child: const Text('Change Server'),
                ),
                PopupMenuItem(
                  onTap: () {
                    voice.leave();
                    ref.read(sessionProvider.notifier).signOut();
                  },
                  child: Text(
                    'Sign Out',
                    style: TextStyle(color: palette.error),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChannelRow extends StatelessWidget {
  const _ChannelRow({
    required this.view,
    required this.gateway,
    required this.voice,
  });

  final ChannelView view;
  final Gateway gateway;
  final Voice voice;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final here = voice.channel == view.channel.id;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: here
              ? palette.accent.withValues(alpha: 0.22)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: view.locked ? null : () => voice.join(view.channel.id),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    view.locked ? Icons.lock_outline : Icons.volume_up_outlined,
                    size: 17,
                    color: view.locked ? palette.tertiary : palette.accent,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      view.channel.name,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: view.locked ? palette.tertiary : palette.text,
                        fontWeight: here ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        for (final p in view.participants)
          Padding(
            padding: const EdgeInsets.fromLTRB(34, 3, 8, 3),
            child: Row(
              children: [
                _Avatar(
                  name: p.displayName,
                  size: 20,
                  speaking: voice.speaking.contains(p.session),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    p.displayName,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: palette.muted, fontSize: 13),
                  ),
                ),
                if (p.serverMuted || voice.micOff.contains(p.session))
                  Icon(Icons.mic_off, size: 14, color: palette.tertiary),
              ],
            ),
          ),
      ],
    );
  }
}

class _CallArea extends StatelessWidget {
  const _CallArea({required this.gateway, required this.voice});

  final Gateway gateway;
  final Voice voice;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final id = voice.channel;
    final view = id == null ? null : gateway.channel(id);
    if (view == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.headphones, size: 40, color: palette.accent),
            const SizedBox(height: 12),
            Text(
              'Pick a Voice Channel',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: palette.text,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Click a channel to join.',
              style: TextStyle(color: palette.muted),
            ),
          ],
        ),
      );
    }
    final status = switch (voice.state) {
      VoiceState.joining => 'Joining…',
      VoiceState.waitingForKey => 'Waiting for the call key…',
      _ => 'End-to-end encrypted',
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
          child: Row(
            children: [
              Text(
                view.channel.name,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: palette.text,
                ),
              ),
              const SizedBox(width: 10),
              Icon(Icons.lock_outline, size: 13, color: palette.muted),
              const SizedBox(width: 4),
              Text(
                status,
                style: TextStyle(fontSize: 12, color: palette.muted),
              ),
            ],
          ),
        ),
        Expanded(
          child: Center(
            child: Wrap(
              spacing: 28,
              runSpacing: 24,
              alignment: WrapAlignment.center,
              children: [
                for (final p in view.participants)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _Avatar(
                        name: p.displayName,
                        size: 84,
                        speaking: voice.speaking.contains(p.session),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (p.serverMuted ||
                              voice.micOff.contains(p.session)) ...[
                            Icon(
                              Icons.mic_off,
                              size: 14,
                              color: palette.tertiary,
                            ),
                            const SizedBox(width: 4),
                          ],
                          Text(
                            p.displayName,
                            style: TextStyle(color: palette.text),
                          ),
                        ],
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _RoundButton(
                icon: voice.muted ? Icons.mic_off : Icons.mic,
                label: voice.muted ? 'Unmute' : 'Mute',
                background: voice.muted
                    ? palette.error.withValues(alpha: 0.25)
                    : palette.fill,
                foreground: voice.muted ? palette.error : palette.text,
                onPressed: voice.state == VoiceState.connected
                    ? voice.toggleMute
                    : null,
              ),
              const SizedBox(width: 16),
              _RoundButton(
                icon: Icons.call_end,
                label: 'Leave',
                background: palette.error,
                foreground: palette.onAccent,
                onPressed: voice.leave,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.icon,
    required this.label,
    required this.background,
    required this.foreground,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final Color background;
  final Color foreground;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: label,
    child: Semantics(
      button: true,
      label: label,
      child: Material(
        color: background,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox(
            width: 56,
            height: 56,
            child: Icon(icon, color: foreground),
          ),
        ),
      ),
    ),
  );
}

/// A person's initial in a circle, ringed in green while they talk.
class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.name,
    required this.size,
    this.speaking = false,
  });

  final String name;
  final double size;
  final bool speaking;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size > 40 ? 3 : 1.5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: speaking ? palette.speaking : Colors.transparent,
          width: size > 40 ? 3 : 1.5,
        ),
      ),
      child: CircleAvatar(
        backgroundColor: palette.accent.withValues(alpha: 0.22),
        foregroundColor: palette.accent,
        child: Text(
          name.characters.isEmpty ? '?' : name.characters.first.toUpperCase(),
          style: TextStyle(fontSize: size * 0.38, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
