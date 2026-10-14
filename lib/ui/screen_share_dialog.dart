// Before sharing: what it's for (text or motion), and which screen or
// window. On Wayland the system asks which screen itself.

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' as rtc;

import '../data/voice.dart';
import '../theme.dart';

typedef ScreenShareChoice = ({String? source, ScreenQuality quality});

/// On Wayland apps can't list screens or windows: a system dialog picks.
/// This libwebrtc offers whole screens only there, and its window capture
/// would crash, so the app never lists windows.
bool get systemPicksScreen =>
    Platform.isLinux && Platform.environment['XDG_SESSION_TYPE'] == 'wayland';

class ScreenShareDialog extends StatefulWidget {
  const ScreenShareDialog({super.key});

  @override
  State<ScreenShareDialog> createState() => _ScreenShareDialogState();
}

class _ScreenShareDialogState extends State<ScreenShareDialog> {
  var _quality = ScreenQuality.text;
  late final Future<List<rtc.DesktopCapturerSource>> _sources =
      systemPicksScreen
      ? Future.value(const [])
      : rtc.desktopCapturer.getSources(
          types: [rtc.SourceType.Screen, rtc.SourceType.Window],
          thumbnailSize: rtc.ThumbnailSize(320, 180),
        );
  String? _source;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final ready = systemPicksScreen || _source != null;
    return AlertDialog(
      title: const Text('Share Your Screen'),
      content: SizedBox(
        width: 560,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SegmentedButton<ScreenQuality>(
              segments: const [
                ButtonSegment(
                  value: ScreenQuality.text,
                  icon: Icon(Icons.article_outlined),
                  label: Text('Text and Slides'),
                ),
                ButtonSegment(
                  value: ScreenQuality.motion,
                  icon: Icon(Icons.sports_esports_outlined),
                  label: Text('Video and Games'),
                ),
              ],
              selected: {_quality},
              onSelectionChanged: (s) => setState(() => _quality = s.single),
            ),
            const SizedBox(height: 8),
            Text(
              _quality == ScreenQuality.text
                  ? 'Sharp and light: a few frames a second.'
                  : 'Smooth: 30 frames a second, heavier on both ends.',
              style: TextStyle(fontSize: 13, color: palette.muted),
            ),
            const SizedBox(height: 16),
            if (systemPicksScreen)
              Text(
                'The first time, your system asks which screen to share. '
                'Later shares reuse that screen until Wisetalk restarts. '
                'Whole screens only, without sound, for now.',
                style: TextStyle(fontSize: 13, color: palette.muted),
              )
            else
              _SourcePicker(
                sources: _sources,
                selected: _source,
                onSelect: (id) => setState(() => _source = id),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: ready
              ? () => Navigator.pop<ScreenShareChoice>(context, (
                  source: _source,
                  quality: _quality,
                ))
              : null,
          child: const Text('Share'),
        ),
      ],
    );
  }
}

class _SourcePicker extends StatelessWidget {
  const _SourcePicker({
    required this.sources,
    required this.selected,
    required this.onSelect,
  });

  final Future<List<rtc.DesktopCapturerSource>> sources;
  final String? selected;
  final void Function(String) onSelect;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return FutureBuilder(
      future: sources,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text(
            "Can't list screens and windows.",
            style: TextStyle(color: palette.error),
          );
        }
        final list = snapshot.data;
        if (list == null) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          );
        }
        return ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 360),
          child: GridView.extent(
            shrinkWrap: true,
            maxCrossAxisExtent: 180,
            childAspectRatio: 16 / 12,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: [
              for (final source in list)
                _SourceTile(
                  source: source,
                  selected: source.id == selected,
                  onTap: () => onSelect(source.id),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _SourceTile extends StatelessWidget {
  const _SourceTile({
    required this.source,
    required this.selected,
    required this.onTap,
  });

  final rtc.DesktopCapturerSource source;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final thumbnail = source.thumbnail;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? palette.accent : palette.separator,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: thumbnail == null || thumbnail.isEmpty
                  ? Icon(
                      source.type == rtc.SourceType.Screen
                          ? Icons.monitor
                          : Icons.web_asset,
                      color: palette.muted,
                    )
                  : Image.memory(
                      thumbnail,
                      fit: BoxFit.contain,
                      gaplessPlayback: true,
                    ),
            ),
            const SizedBox(height: 4),
            Text(
              source.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, color: palette.text),
            ),
          ],
        ),
      ),
    );
  }
}

/// Has the system ask which screen to share, and waits for the answer:
/// the source to share, or `null` if the person backed out.
///
/// Sharing on Wayland goes through a portal session twice: once for the
/// source list, once for the capture. Asked at once, the system shows two
/// dialogs. The capture reuses the list's answer (WebRTC keeps a restore
/// token for it) only once that answer is in, so this waits for the list's
/// first frame before handing the source over.
///
/// libwebrtc keeps that list, and its answer, for the life of the app:
/// later shares return at once with the same screen. Asking every time
/// needs a libwebrtc that makes a fresh list per share.
Future<String?> askSystemForScreen(BuildContext context) => showDialog<String>(
  context: context,
  barrierDismissible: false,
  builder: (context) => const _SystemPicker(),
);

class _SystemPicker extends StatefulWidget {
  const _SystemPicker();

  @override
  State<_SystemPicker> createState() => _SystemPickerState();
}

class _SystemPickerState extends State<_SystemPicker> {
  bool _done = false;

  @override
  void initState() {
    super.initState();
    unawaited(_wait());
  }

  @override
  void dispose() {
    _done = true;
    super.dispose();
  }

  Future<void> _wait() async {
    String? picked;
    try {
      final sources = await rtc.desktopCapturer.getSources(
        types: [rtc.SourceType.Screen],
        thumbnailSize: rtc.ThumbnailSize(16, 9),
      );
      final source = sources.firstOrNull;
      // Every half second until the person answers: the list's capturer
      // has a frame only once they have.
      for (var i = 0; source != null && !_done && i < 600; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 500));
        if (_done) break;
        try {
          final frame = await rtc.WebRTC.invokeMethod<Uint8List, dynamic>(
            'getDesktopSourceThumbnail',
            {
              'sourceId': source.id,
              'thumbnailSize': {'width': 16, 'height': 9},
            },
          );
          if (frame != null && frame.isNotEmpty) {
            picked = source.id;
            break;
          }
        } catch (_) {
          // No frame yet.
        }
      }
    } catch (e) {
      debugPrint('cannot ask the system for a screen: $e');
    }
    if (!_done && mounted) Navigator.pop(context, picked);
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Choose a Screen'),
    content: Text(
      "Pick the screen to share in your system's window.",
      style: TextStyle(color: context.palette.muted),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
    ],
  );
}
