// How the call's connection is doing: everyone's connection quality as the
// server rates it, and our own numbers, measured only while someone looks.
//
// Both live apart from Voice's notifyListeners, which rebuilds the whole
// window: a quality change or a new number repaints only what shows it.
// Nothing here runs on its own (ADR-0019): qualities change when LiveKit
// says so, and the numbers' timer exists only while it has watchers.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:livekit_client/livekit_client.dart' as lk;

import 'link_stats.dart';

/// Each participant's connection quality, by session id (the LiveKit
/// identity). One notifier per person, so their icon rebuilds alone.
class Qualities {
  final Map<String, ValueNotifier<lk.ConnectionQuality>> _of = {};

  /// Ask only for people in our call: the map keeps whoever was asked for.
  ValueListenable<lk.ConnectionQuality> of(String session) => _of.putIfAbsent(
    session,
    () => ValueNotifier(lk.ConnectionQuality.unknown),
  );

  /// Notifies only when the quality actually changed.
  void set(String session, lk.ConnectionQuality quality) =>
      (of(session) as ValueNotifier<lk.ConnectionQuality>).value = quality;

  /// Out of the call: nobody's quality is known any more.
  void clear() {
    for (final notifier in _of.values) {
      notifier.value = lk.ConnectionQuality.unknown;
    }
  }

  void dispose() {
    for (final notifier in _of.values) {
      notifier.dispose();
    }
    _of.clear();
  }
}

/// Our numbers, once a second while at least one widget watches them: the
/// popover while open, the numbers next to the icon while the window shows.
/// `null` until the first round comes back.
class LinkMonitor extends ValueNotifier<LinkStats?> {
  LinkMonitor(this._sample, {Duration Function()? clock})
    : _clock = clock ?? Stopwatch().elapsedFunction(),
      super(null);

  /// One round of getStats(); `null` out of a call.
  final Future<LinkSample?> Function(Duration at) _sample;
  final Duration Function() _clock;

  static const period = Duration(seconds: 1);

  Timer? _timer;
  int _watchers = 0;
  bool _busy = false;
  LinkSample? _last;

  /// Whether the timer runs, for tests.
  @visibleForTesting
  bool get running => _timer != null;

  void watch() {
    if (_watchers++ > 0) return;
    _timer = Timer.periodic(period, (_) => unawaited(_tick()));
    unawaited(_tick());
  }

  void unwatch() {
    if (_watchers == 0 || --_watchers > 0) return;
    _timer?.cancel();
    _timer = null;
    // A later look starts fresh, not with deltas over the pause.
    _last = null;
    value = null;
  }

  /// Out of the call: what was measured belongs to the old one.
  void reset() {
    _last = null;
    value = null;
  }

  Future<void> _tick() async {
    // A slow getStats() skips a beat rather than piling up.
    if (_busy) return;
    _busy = true;
    try {
      final sample = await _sample(_clock());
      if (_timer == null) return;
      if (sample == null) {
        _last = null;
        value = null;
        return;
      }
      value = compareStats(sample, _last);
      _last = sample;
    } finally {
      _busy = false;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }
}

extension on Stopwatch {
  Duration Function() elapsedFunction() {
    start();
    return () => elapsed;
  }
}
