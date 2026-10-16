// Signal bars for how a connection is doing (ADR-0028). Ours sits next to
// the lock above the stage, colored from the quality the server rates, and
// opens a popover with the numbers; with Show Ping and Loss on, ping and
// loss sit next to it. Others get bars only when their connection is poor
// or lost, next to their name.
//
// The quality comes from LiveKit's events, so the bars cost nothing while
// nothing changes. The numbers need getStats() once a second, and that
// timer runs only while the popover is open, or while the numbers are on
// and the window shows (ADR-0019).

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart' as lk;

import '../data/link.dart';
import '../data/link_stats.dart';
import '../data/preferences.dart';
import '../l10n/app_localizations.dart';
import '../theme.dart';

String qualityWord(AppLocalizations texts, lk.ConnectionQuality quality) =>
    switch (quality) {
      lk.ConnectionQuality.excellent => texts.connectionExcellent,
      lk.ConnectionQuality.good => texts.connectionGood,
      lk.ConnectionQuality.poor => texts.connectionPoor,
      lk.ConnectionQuality.lost => texts.connectionLost,
      lk.ConnectionQuality.unknown => texts.connectionChecking,
    };

Color _colorOf(Palette palette, lk.ConnectionQuality quality) =>
    switch (quality) {
      lk.ConnectionQuality.excellent => palette.speaking,
      lk.ConnectionQuality.good => palette.warning,
      lk.ConnectionQuality.poor => palette.error,
      lk.ConnectionQuality.lost => palette.tertiary,
      lk.ConnectionQuality.unknown => palette.fill,
    };

/// Three bars, as many lit as the quality earns; lost is all gray.
class SignalBars extends StatelessWidget {
  const SignalBars({super.key, required this.quality, this.size = 14});

  final lk.ConnectionQuality quality;
  final double size;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final lit = switch (quality) {
      lk.ConnectionQuality.excellent => 3,
      lk.ConnectionQuality.good => 2,
      lk.ConnectionQuality.poor => 1,
      lk.ConnectionQuality.lost => 3,
      lk.ConnectionQuality.unknown => 0,
    };
    return CustomPaint(
      size: Size.square(size),
      painter: _BarsPainter(
        lit: lit,
        color: _colorOf(palette, quality),
        unlit: palette.fill,
      ),
    );
  }
}

class _BarsPainter extends CustomPainter {
  const _BarsPainter({
    required this.lit,
    required this.color,
    required this.unlit,
  });

  final int lit;
  final Color color;
  final Color unlit;

  @override
  void paint(Canvas canvas, Size size) {
    const bars = 3;
    final gap = size.width / 7;
    final width = (size.width - gap * (bars - 1)) / bars;
    for (var i = 0; i < bars; i++) {
      final height = size.height * (i + 2) / (bars + 1);
      final rect = Rect.fromLTWH(
        i * (width + gap),
        size.height - height,
        width,
        height,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(width / 3)),
        Paint()..color = i < lit ? color : unlit,
      );
    }
  }

  @override
  bool shouldRepaint(_BarsPainter old) =>
      old.lit != lit || old.color != color || old.unlit != unlit;
}

/// Someone else's bars, shown only while their connection is poor or lost.
/// Rebuilds alone when their quality changes.
class QualityMark extends StatelessWidget {
  const QualityMark({super.key, required this.quality, this.size = 13});

  final ValueListenable<lk.ConnectionQuality> quality;
  final double size;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder(
    valueListenable: quality,
    builder: (context, quality, _) {
      if (quality != lk.ConnectionQuality.poor &&
          quality != lk.ConnectionQuality.lost) {
        return const SizedBox.shrink();
      }
      final texts = AppLocalizations.of(context);
      final word = texts.connectionStatus(qualityWord(texts, quality));
      return Tooltip(
        message: word,
        child: Semantics(
          label: word,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: RepaintBoundary(
              child: SignalBars(quality: quality, size: size),
            ),
          ),
        ),
      );
    },
  );
}

/// Our own bars above the stage, with the numbers behind them.
class ConnectionStatus extends StatefulWidget {
  const ConnectionStatus({
    super.key,
    required this.quality,
    required this.link,
    required this.preferences,
  });

  final ValueListenable<lk.ConnectionQuality> quality;
  final LinkMonitor link;
  final Preferences preferences;

  @override
  State<ConnectionStatus> createState() => _ConnectionStatusState();
}

class _ConnectionStatusState extends State<ConnectionStatus> {
  final _popover = OverlayPortalController();
  final _anchor = LayerLink();
  late final AppLifecycleListener _lifecycle;

  /// Whether the window shows: resumed, or visible without focus.
  bool _visible = true;

  /// Opened by a tap, so leaving it with the mouse doesn't close it.
  bool _pinned = false;

  /// What this widget asked [LinkMonitor] for, to give back exactly that.
  bool _watchingPopover = false;
  bool _watchingNumbers = false;

  bool get _numbers => widget.preferences.showPingAndLoss && _visible;

  @override
  void initState() {
    super.initState();
    _visible = _shows(WidgetsBinding.instance.lifecycleState);
    _lifecycle = AppLifecycleListener(
      onStateChange: (state) {
        final visible = _shows(state);
        if (visible == _visible) return;
        setState(() => _visible = visible);
        if (!visible) _close();
        _syncNumbers();
      },
    );
    widget.preferences.addListener(_preferencesChanged);
    _syncNumbers();
  }

  static bool _shows(AppLifecycleState? state) =>
      state == null ||
      state == AppLifecycleState.resumed ||
      state == AppLifecycleState.inactive;

  @override
  void didUpdateWidget(ConnectionStatus old) {
    super.didUpdateWidget(old);
    if (old.preferences != widget.preferences) {
      old.preferences.removeListener(_preferencesChanged);
      widget.preferences.addListener(_preferencesChanged);
    }
    if (old.link != widget.link) {
      if (_watchingPopover) {
        old.link.unwatch();
        widget.link.watch();
      }
      if (_watchingNumbers) {
        old.link.unwatch();
        widget.link.watch();
      }
    }
    _syncNumbers();
  }

  @override
  void dispose() {
    widget.preferences.removeListener(_preferencesChanged);
    _lifecycle.dispose();
    if (_watchingPopover) widget.link.unwatch();
    if (_watchingNumbers) widget.link.unwatch();
    super.dispose();
  }

  void _preferencesChanged() {
    if (_numbers == _watchingNumbers) return;
    setState(_syncNumbers);
  }

  void _syncNumbers() {
    if (_numbers == _watchingNumbers) return;
    _watchingNumbers = _numbers;
    _numbers ? widget.link.watch() : widget.link.unwatch();
  }

  void _open({required bool pin}) {
    _pinned = _pinned || pin;
    if (_popover.isShowing) return;
    _popover.show();
    _watchingPopover = true;
    widget.link.watch();
  }

  void _close() {
    _pinned = false;
    if (!_popover.isShowing) return;
    _popover.hide();
    _watchingPopover = false;
    widget.link.unwatch();
  }

  /// Phones open and close it by tapping; with a mouse it's open while
  /// hovering, and a click keeps it open.
  void _tapped() {
    if (_popover.isShowing && _pinned) {
      _close();
    } else {
      _open(pin: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final texts = AppLocalizations.of(context);
    return TapRegion(
      groupId: this,
      onTapOutside: (_) => _close(),
      child: OverlayPortal(
        controller: _popover,
        overlayChildBuilder: _popoverBuilder,
        child: CompositedTransformTarget(
          link: _anchor,
          child: InkWell(
            borderRadius: BorderRadius.circular(6),
            onTap: _tapped,
            onHover: (inside) {
              if (inside) {
                _open(pin: false);
              } else if (!_pinned) {
                _close();
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // A quality change repaints the bars and nothing else.
                  RepaintBoundary(
                    child: ValueListenableBuilder(
                      valueListenable: widget.quality,
                      builder: (context, quality, _) {
                        final status = qualityWord(texts, quality);
                        final word = texts.connectionStatus(status);
                        return Tooltip(
                          message: word,
                          // The popover opens below.
                          preferBelow: false,
                          excludeFromSemantics: true,
                          child: Semantics(
                            button: true,
                            label: word,
                            child: SignalBars(quality: quality),
                          ),
                        );
                      },
                    ),
                  ),
                  if (_watchingNumbers) ...[
                    const SizedBox(width: 6),
                    RepaintBoundary(
                      child: ValueListenableBuilder(
                        valueListenable: widget.link,
                        builder: (context, stats, _) {
                          final ping = formatMs(stats?.ping, texts: texts);
                          final loss = formatLoss(stats?.loss);
                          return Semantics(
                            label: texts.connectionPingLoss(ping, loss),
                            excludeSemantics: true,
                            child: Text(
                              texts.connectionShort(ping, loss),
                              style: TextStyle(
                                fontSize: 12,
                                color: palette.muted,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _popoverBuilder(BuildContext context) {
    final palette = context.palette;
    final texts = AppLocalizations.of(context);
    return Positioned(
      left: 0,
      top: 0,
      width: 248,
      child: CompositedTransformFollower(
        link: _anchor,
        showWhenUnlinked: false,
        targetAnchor: Alignment.bottomCenter,
        followerAnchor: Alignment.topCenter,
        offset: const Offset(0, 6),
        child: TapRegion(
          groupId: this,
          child: Material(
            color: palette.cell,
            elevation: 8,
            shadowColor: Colors.black54,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
              child: ValueListenableBuilder(
                valueListenable: widget.link,
                builder: (context, stats, _) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ValueListenableBuilder(
                      valueListenable: widget.quality,
                      builder: (context, quality, _) => _Row(
                        texts.connectionLabel,
                        qualityWord(texts, quality),
                        color: quality == lk.ConnectionQuality.unknown
                            ? null
                            : _colorOf(palette, quality),
                      ),
                    ),
                    _Row(
                      texts.connectionPing,
                      formatMs(stats?.ping, texts: texts),
                    ),
                    _Row(
                      texts.connectionOutgoingLoss,
                      formatLoss(stats?.outgoingLoss),
                    ),
                    _Row(
                      texts.connectionIncomingLoss,
                      formatLoss(stats?.incomingLoss),
                    ),
                    _Row(
                      texts.connectionJitter,
                      formatMs(stats?.jitter, texts: texts),
                    ),
                    _Row(texts.connectionMicrophone, _microphone(texts, stats)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static String _microphone(AppLocalizations texts, LinkStats? stats) {
    if (stats == null) return '—';
    if (!stats.microphone) return texts.connectionNotSending;
    final bitrate = switch (stats.bitrate) {
      final value? => texts.connectionKilobits(value),
      null => '—',
    };
    return '${stats.codec ?? '—'} · $bitrate';
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value, {this.color});

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 13, color: palette.muted),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: color ?? palette.text,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
