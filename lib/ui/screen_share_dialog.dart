// Before sharing: what it's for (text or motion), and which screen or
// window. On Wayland the system asks which screen itself.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' as rtc;

import '../data/voice.dart';
import '../theme.dart';

typedef ScreenShareChoice = ({String? source, ScreenQuality quality});

/// On Wayland apps can't list screens or windows: a system dialog picks.
/// This libwebrtc offers whole screens only there, and its window capture
/// would crash, so the app never lists sources itself.
bool get _systemPicks =>
    Platform.isLinux && Platform.environment['XDG_SESSION_TYPE'] == 'wayland';

class ScreenShareDialog extends StatefulWidget {
  const ScreenShareDialog({super.key});

  @override
  State<ScreenShareDialog> createState() => _ScreenShareDialogState();
}

class _ScreenShareDialogState extends State<ScreenShareDialog> {
  var _quality = ScreenQuality.text;
  late final Future<List<rtc.DesktopCapturerSource>> _sources = _systemPicks
      ? Future.value(const [])
      : rtc.desktopCapturer.getSources(
          types: [rtc.SourceType.Screen, rtc.SourceType.Window],
          thumbnailSize: rtc.ThumbnailSize(320, 180),
        );
  String? _source;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final ready = _systemPicks || _source != null;
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
            if (_systemPicks)
              Text(
                'Your system asks which screen to share next. If it asks '
                'twice, answer one and close the other. Whole screens only, '
                'without sound, for now.',
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
