// The middle of the window while in a channel: who's there, their cameras
// and screens, and the call controls.

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart' as lk;

import '../data/gateway.dart';
import '../data/protocol.dart';
import '../data/voice.dart';
import '../theme.dart';
import 'common.dart';
import 'connection_status.dart';
import 'grid.dart';
import 'screen_share_dialog.dart';

const _gap = 8.0;
const _stagePadding = 16.0;

class CallArea extends StatefulWidget {
  const CallArea({
    super.key,
    required this.gateway,
    required this.voice,
    this.showName = true,
    this.actions = const [],
  });

  final Gateway gateway;
  final Voice voice;

  /// Buttons at the end of the call's title row.
  final List<Widget> actions;

  /// Off on phones, where the row above the stage names the channel.
  final bool showName;

  @override
  State<CallArea> createState() => _CallAreaState();
}

class _CallAreaState extends State<CallArea> {
  /// The tile zoomed in to fill the stage, by track sid.
  String? _focused;

  Voice get _voice => widget.voice;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final id = _voice.channel;
    final view = id == null ? null : widget.gateway.channel(id);
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
    final status = switch (_voice.state) {
      VoiceState.joining => 'Joining…',
      VoiceState.waitingForKey => 'Waiting for the call key…',
      _ => 'End-to-end encrypted',
    };
    if (_focused != null && !_voice.tiles.any((t) => t.id == _focused)) {
      _focused = null;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
          child: Row(
            children: [
              if (widget.showName) ...[
                Text(
                  view.channel.name,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: palette.text,
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Icon(Icons.lock_outline, size: 13, color: palette.muted),
              const SizedBox(width: 4),
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        status,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: palette.muted),
                      ),
                    ),
                    if (_voice.state == VoiceState.connected &&
                        _voice.gateway.sessionId != null) ...[
                      const SizedBox(width: 6),
                      ConnectionStatus(
                        quality: _voice.qualities.of(_voice.gateway.sessionId!),
                        link: _voice.link,
                        preferences: _voice.preferences,
                      ),
                    ],
                  ],
                ),
              ),
              ...widget.actions,
            ],
          ),
        ),
        Expanded(
          child: _voice.tiles.isEmpty
              ? _People(view: view, voice: _voice)
              : _VideoGrid(
                  view: view,
                  voice: _voice,
                  focused: _focused,
                  onTap: (tile) => setState(
                    () => _focused = _focused == tile.id ? null : tile.id,
                  ),
                ),
        ),
        CallControls(gateway: widget.gateway, voice: _voice),
      ],
    );
  }
}

/// Mute, camera, screen and leave, under the stage.
class CallControls extends StatelessWidget {
  const CallControls({super.key, required this.gateway, required this.voice});

  final Gateway gateway;
  final Voice voice;

  Future<void> _toggleScreen(BuildContext context) async {
    if (voice.screen) return voice.stopScreen();
    final choice = await showDialog<ScreenShareChoice>(
      context: context,
      builder: (context) => const ScreenShareDialog(),
    );
    if (choice == null || !context.mounted) return;
    if (!systemPicksScreen) {
      return voice.startScreen(source: choice.source, quality: choice.quality);
    }
    final source = await askSystemForScreen(context);
    if (source != null) {
      await voice.startScreen(source: source, quality: choice.quality);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final id = voice.channel;
    final view = id == null ? null : gateway.channel(id);
    final connected = voice.state == VoiceState.connected;
    final canStream = connected && (view?.can('VIDEO') ?? false);
    // iOS needs a broadcast extension to share its screen; not yet.
    final canShareScreen = canStream && !Platform.isIOS;
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 20),
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
            onPressed: connected ? voice.toggleMute : null,
          ),
          if (canStream) ...[
            const SizedBox(width: 16),
            _RoundButton(
              icon: voice.camera ? Icons.videocam : Icons.videocam_off,
              label: voice.camera ? 'Turn Camera Off' : 'Turn Camera On',
              background: voice.camera
                  ? palette.accent.withValues(alpha: 0.25)
                  : palette.fill,
              foreground: voice.camera ? palette.accent : palette.text,
              onPressed: voice.toggleCamera,
            ),
          ],
          if (canShareScreen) ...[
            const SizedBox(width: 16),
            _RoundButton(
              icon: voice.screen ? Icons.stop_screen_share : Icons.screen_share,
              label: voice.screen ? 'Stop Sharing' : 'Share Screen',
              background: voice.screen
                  ? palette.accent.withValues(alpha: 0.25)
                  : palette.fill,
              foreground: voice.screen ? palette.accent : palette.text,
              onPressed: () => _toggleScreen(context),
            ),
          ],
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
    );
  }
}

/// Everyone in the call as avatars, while nobody shows video.
class _People extends StatelessWidget {
  const _People({required this.view, required this.voice});

  final ChannelView view;
  final Voice voice;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Center(
      child: Wrap(
        spacing: 28,
        runSpacing: 24,
        alignment: WrapAlignment.center,
        children: [
          for (final p in view.participants)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Avatar(
                  name: p.displayName,
                  size: 84,
                  image: voice.gateway.avatar(p.account, p.avatar),
                  speaking: voice.speaking.contains(p.session),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (p.serverMuted || voice.micOff.contains(p.session)) ...[
                      Icon(Icons.mic_off, size: 14, color: palette.tertiary),
                      const SizedBox(width: 4),
                    ],
                    Text(p.displayName, style: TextStyle(color: palette.text)),
                    if (p.session != voice.gateway.sessionId)
                      QualityMark(quality: voice.qualities.of(p.session)),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }
}

/// Cameras and screens in equal tiles, as large as the stage allows. People
/// without a camera get a tile with their avatar, unless one video is
/// zoomed in.
class _VideoGrid extends StatelessWidget {
  const _VideoGrid({
    required this.view,
    required this.voice,
    required this.focused,
    required this.onTap,
  });

  final ChannelView view;
  final Voice voice;
  final String? focused;
  final void Function(VideoTile) onTap;

  @override
  Widget build(BuildContext context) {
    final tiles = focused == null
        ? voice.tiles
        : [
            for (final t in voice.tiles)
              if (t.id == focused) t,
          ];
    final cameraless = focused != null
        ? const <Participant>[]
        : [
            for (final p in view.participants)
              if (!tiles.any((t) => t.session == p.session && !t.screen)) p,
          ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final grid = bestGrid(
          tiles.length + cameraless.length,
          constraints.maxWidth - _stagePadding * 2,
          constraints.maxHeight - _stagePadding * 2,
          gap: _gap,
        );
        final size = Size(grid.tileWidth, grid.tileWidth * 9 / 16);
        return Padding(
          padding: const EdgeInsets.all(_stagePadding),
          child: Center(
            child: Wrap(
              spacing: _gap,
              runSpacing: _gap,
              alignment: WrapAlignment.center,
              children: [
                for (final tile in tiles)
                  SizedBox.fromSize(
                    key: ValueKey(tile.id),
                    size: size,
                    child: _VideoTileView(
                      tile: tile,
                      quality: tile.local
                          ? null
                          : voice.qualities.of(tile.session),
                      focused: tile.id == focused,
                      onTap: () => onTap(tile),
                    ),
                  ),
                for (final p in cameraless)
                  SizedBox.fromSize(
                    key: ValueKey('person:${p.session}'),
                    size: size,
                    child: _PersonTile(
                      participant: p,
                      quality: p.session == voice.gateway.sessionId
                          ? null
                          : voice.qualities.of(p.session),
                      image: voice.gateway.avatar(p.account, p.avatar),
                      speaking: voice.speaking.contains(p.session),
                      size: size,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _VideoTileView extends StatelessWidget {
  const _VideoTileView({
    required this.tile,
    required this.quality,
    required this.focused,
    required this.onTap,
  });

  final VideoTile tile;

  /// Someone else's connection, for bars when it's poor.
  final ValueListenable<lk.ConnectionQuality>? quality;
  final bool focused;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Video repaints on its own every frame; keep that from the rest.
    return RepaintBoundary(
      child: MouseRegion(
        cursor: focused
            ? SystemMouseCursors.zoomOut
            : SystemMouseCursors.zoomIn,
        child: GestureDetector(
          onTap: onTap,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: ColoredBox(
              color: Colors.black,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  lk.VideoTrackRenderer(
                    tile.track,
                    fit: lk.VideoViewFit.contain,
                    mirrorMode: tile.local && !tile.screen
                        ? lk.VideoViewMirrorMode.mirror
                        : lk.VideoViewMirrorMode.off,
                  ),
                  Positioned(
                    left: 8,
                    bottom: 6,
                    child: _Label(
                      tile.screen ? '${tile.name} · screen' : tile.name,
                      quality: quality,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PersonTile extends StatelessWidget {
  const _PersonTile({
    required this.participant,
    required this.quality,
    required this.image,
    required this.speaking,
    required this.size,
  });

  final Participant participant;
  final ValueListenable<lk.ConnectionQuality>? quality;
  final Uri? image;
  final bool speaking;
  final Size size;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.cell,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: Avatar(
              name: participant.displayName,
              size: (size.width / 4).clamp(40, 112),
              image: image,
              speaking: speaking,
            ),
          ),
          Positioned(
            left: 8,
            bottom: 6,
            child: _Label(participant.displayName, quality: quality),
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text, {this.quality});

  final String text;

  /// Bars after the name while this connection is poor or lost.
  final ValueListenable<lk.ConnectionQuality>? quality;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: Colors.black.withValues(alpha: 0.55),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (quality case final quality?) QualityMark(quality: quality),
        ],
      ),
    ),
  );
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
