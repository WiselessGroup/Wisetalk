// Signed in: the channel list in a floating sidebar, the call beside it.
// The same layout as the web client, without settings yet.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/address.dart';
import '../data/chat.dart';
import '../data/connection.dart';
import '../data/gateway.dart';
import '../data/notifications.dart';
import '../data/protocol.dart';
import '../data/servers.dart';
import '../data/session.dart';
import '../data/updates.dart';
import '../data/voice.dart';
import '../theme.dart';
import 'call_stage.dart';
import 'chat_panel.dart';
import 'common.dart';

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
  Chats get _chats => widget.connection.chats;
  late final Listenable _changes = Listenable.merge([
    _gateway,
    _voice,
    _chats,
    ref.read(updatesProvider),
  ]);
  String? _shownError;

  /// Whether Wisetalk is the window in front: notifications only when not.
  bool _focused = true;
  late final AppLifecycleListener _lifecycle;
  final List<StreamSubscription<Object?>> _subscriptions = [];

  @override
  void initState() {
    super.initState();
    _voice.addListener(_voiceChanged);
    _chats.addListener(_chatsChanged);
    _lifecycle = AppLifecycleListener(
      onStateChange: (state) => _focused = state == AppLifecycleState.resumed,
    );
    final notifications = ref.read(notificationsProvider);
    _subscriptions.addAll([
      _chats.incoming.listen(_message),
      _gateway.events.listen(_event),
      notifications.clicks.listen(_clicked),
    ]);
  }

  @override
  void dispose() {
    _voice.removeListener(_voiceChanged);
    _chats.removeListener(_chatsChanged);
    _lifecycle.dispose();
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    super.dispose();
  }

  String _channelName(String id) =>
      _gateway.channel(id)?.channel.name ?? 'a channel';

  /// Someone else wrote in a chat we follow (ours, or the call's) while
  /// Wisetalk is in the background.
  void _message(ChatMessage message) {
    final me = widget.session.me;
    final ours = message.author == null
        ? me.isGuest && message.authorName == me.displayName
        : message.author == me.id;
    final followed =
        message.channel == _voice.channel ||
        _chats.opened.contains(message.channel);
    if (ours || !followed || _focused) return;
    final text = message.text;
    unawaited(
      ref
          .read(notificationsProvider)
          .show(
            title: '${message.authorName} in ${_channelName(message.channel)}',
            body: text == null
                ? 'Wrote an encrypted message.'
                : text.isNotEmpty
                ? text
                : 'Sent a picture.',
            target: ChatTarget(message.channel),
          ),
    );
  }

  void _event(GatewayEvent event) {
    if (event.type != 'summoned' || !mounted) return;
    final data = event.data as Map<String, dynamic>;
    final channel = data['channel'] as String;
    final from = data['from'] as String;
    final text = '$from summons you to ${_channelName(channel)}.';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 100),
        duration: const Duration(seconds: 10),
        action: SnackBarAction(
          label: 'Join',
          onPressed: () => _voice.join(channel),
        ),
      ),
    );
    if (!_focused) {
      unawaited(
        ref
            .read(notificationsProvider)
            .show(title: 'Summoned', body: text, target: SummonTarget(channel)),
      );
    }
  }

  void _clicked(NotificationTarget target) {
    switch (target) {
      case ChatTarget(:final channel):
        unawaited(_chats.show(channel));
      case SummonTarget(:final channel):
        _voice.join(channel);
    }
  }

  void _toast(String text) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(text),
      // Floats above the call controls instead of covering them.
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 100),
    ),
  );

  void _chatsChanged() {
    final error = _chats.error;
    if (error != null && mounted) {
      _chats.error = null;
      _toast(error);
    }
    // A chat that went out of reach closes itself.
    final open = _chats.open;
    if (open != null && _gateway.status == GatewayStatus.ready) {
      final view = _gateway.channel(open);
      if (view == null || view.locked) _chats.hide();
    }
  }

  /// Errors show once as a toast; the take-over question as a dialog.
  void _voiceChanged() {
    final error = _voice.error;
    if (error != null && error != _shownError && mounted) {
      _shownError = error;
      _toast(error);
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
          builder: (context, _) {
            final open = _chats.open;
            final chat = open == null ? null : _gateway.channel(open);
            final inCall = _voice.channel != null;
            final panel = chat == null
                ? null
                : _Card(
                    child: ChatPanel(
                      key: ValueKey(chat.channel.id),
                      chats: _chats,
                      gateway: _gateway,
                      view: chat,
                      onClose: _chats.hide,
                    ),
                  );
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: _Sidebar(
                    gateway: _gateway,
                    voice: _voice,
                    chats: _chats,
                    updates: ref.read(updatesProvider),
                    session: widget.session,
                  ),
                ),
                // Out of a call the chat takes the whole stage.
                if (panel != null && !inCall)
                  Expanded(child: panel)
                else ...[
                  Expanded(
                    child: CallArea(gateway: _gateway, voice: _voice),
                  ),
                  if (panel != null) SizedBox(width: 380, child: panel),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

/// A floating panel like the sidebar, for the chat.
class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: palette.sidebar,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: palette.separator, width: 0.5),
        ),
        child: child,
      ),
    );
  }
}

class _Sidebar extends ConsumerWidget {
  const _Sidebar({
    required this.gateway,
    required this.voice,
    required this.chats,
    required this.updates,
    required this.session,
  });

  final Gateway gateway;
  final Voice voice;
  final Chats chats;
  final Updates updates;
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
                  _ChannelRow(
                    view: view,
                    gateway: gateway,
                    voice: voice,
                    chats: chats,
                  ),
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
                    _ChannelRow(
                      view: view,
                      gateway: gateway,
                      voice: voice,
                      chats: chats,
                    ),
                ],
              ],
            ),
          ),
          if (updates.ready != null || updates.available != null)
            _UpdateButton(updates: updates),
          Divider(height: 1, color: palette.separator),
          ListTile(
            dense: true,
            leading: Avatar(
              name: session.me.displayName,
              size: 30,
              image: gateway.avatar(session.me.id, session.me.avatar),
            ),
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
                  enabled: false,
                  child: Text('Wisetalk $versionName'),
                ),
                const PopupMenuDivider(),
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
    required this.chats,
  });

  final ChannelView view;
  final Gateway gateway;
  final Voice voice;
  final Chats chats;

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
                  if (!view.locked)
                    _ChatButton(
                      open: chats.open == view.channel.id,
                      unread: chats.unread[view.channel.id] ?? 0,
                      onPressed: () => chats.open == view.channel.id
                          ? chats.hide()
                          : chats.show(view.channel.id),
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
                Avatar(
                  name: p.displayName,
                  size: 20,
                  image: gateway.avatar(p.account, p.avatar),
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

/// Opens a channel's chat; shows how many messages came in unseen.
class _ChatButton extends StatelessWidget {
  const _ChatButton({
    required this.open,
    required this.unread,
    required this.onPressed,
  });

  final bool open;
  final int unread;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Tooltip(
      message: open ? 'Close Chat' : 'Open Chat',
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Badge(
            isLabelVisible: unread > 0,
            label: Text(unread > 99 ? '99+' : '$unread'),
            backgroundColor: palette.accent,
            textColor: palette.onAccent,
            child: Icon(
              open ? Icons.chat_bubble : Icons.chat_bubble_outline,
              size: 17,
              color: open || unread > 0 ? palette.accent : palette.tertiary,
            ),
          ),
        ),
      ),
    );
  }
}

/// Shows once a new version is waiting: restarts into it on desktop, gets
/// the APK on Android.
class _UpdateButton extends StatelessWidget {
  const _UpdateButton({required this.updates});

  final Updates updates;

  @override
  Widget build(BuildContext context) {
    final ready = updates.ready;
    final available = updates.available;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
      child: Tooltip(
        message: ready != null
            ? 'Wisetalk $ready is downloaded'
            : 'Wisetalk ${available?.version} is out',
        child: FilledButton.icon(
          icon: const Icon(Icons.system_update_alt, size: 18),
          label: Text(
            ready != null
                ? 'Restart to Update'
                : 'Update to ${available?.version}',
          ),
          onPressed: ready != null
              ? updates.restart
              : () => launchUrl(
                  available!.url,
                  mode: LaunchMode.externalApplication,
                ),
        ),
      ),
    );
  }
}
