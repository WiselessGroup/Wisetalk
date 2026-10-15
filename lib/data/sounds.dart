// Owl hoots for people coming into and leaving your call, the web client's
// lib/sounds.ts: made on the fly, nothing to download or license. Arriving
// hoots go up a fourth (G4 to C5), leaving ones come back down (C5 to G4),
// softer. Shortcuts answer with ticks of the same make (ADR-0027): one
// sliding down when the microphone goes off, up when it comes on, two for
// stepping away and coming back. Android plays them in Kotlin as voice call
// sounds; elsewhere audioplayers plays a WAV file made once per run.

import 'dart:io';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

enum Cue {
  join(392, 523.25, 0.112),
  leave(523.25, 392, 0.084),
  mute(1046.5, 784, 0.07, ticks: 1),
  unmute(784, 1046.5, 0.07, ticks: 1),
  away(1046.5, 784, 0.07, ticks: 2),
  back(784, 1046.5, 0.07, ticks: 2);

  const Cue(this.first, this.second, this.level, {this.ticks = 0});

  /// Hoots: the first and second note. Ticks: where each starts and ends.
  final double first;
  final double second;
  final double level;

  /// How many ticks; none for the owl's two hoots.
  final int ticks;
}

const _rate = 48000;
const _android = MethodChannel('net.wiseless.wisetalk/sound');

class Sounds {
  final _pcm = <Cue, Uint8List>{};
  final _files = <Cue, String>{};
  final _players = <Cue, AudioPlayer>{};

  /// Plays [cue]; a cue is never worth an error.
  Future<void> play(Cue cue) async {
    try {
      final pcm = _pcm[cue] ??= _synthesize(cue);
      if (Platform.isAndroid) {
        await _android.invokeMethod<void>('play', {'pcm': pcm, 'rate': _rate});
        return;
      }
      final path = _files[cue] ??= await _write(cue, pcm);
      final player = _players[cue] ??= AudioPlayer()
        ..setReleaseMode(ReleaseMode.stop);
      await player.play(DeviceFileSource(path));
    } catch (e) {
      debugPrint('a sound cue did not play: $e');
    }
  }

  Future<String> _write(Cue cue, Uint8List pcm) async {
    final folder = await getTemporaryDirectory();
    final file = File('${folder.path}/wisetalk-${cue.name}.wav');
    await file.writeAsBytes(_wav(pcm));
    return file.path;
  }
}

/// The app's one set of cues.
final sounds = Sounds();

/// A cue as 16-bit mono PCM: two hoots, the second a little longer, or
/// its ticks.
Uint8List _synthesize(Cue cue) {
  const start = 0.02;
  final Float64List samples;
  if (cue.ticks == 0) {
    samples = Float64List((_rate * 0.6).round());
    _hoot(samples, start, cue.first, cue.level, 0.2);
    _hoot(samples, start + 0.26, cue.second, cue.level, 0.26);
  } else {
    samples = Float64List((_rate * (0.1 + cue.ticks * 0.1)).round());
    for (var i = 0; i < cue.ticks; i++) {
      _tick(samples, start + i * 0.1, cue.first, cue.second, cue.level);
    }
  }
  final pcm = ByteData(samples.length * 2);
  for (var i = 0; i < samples.length; i++) {
    final value = (samples[i] * 32767).round().clamp(-32768, 32767);
    pcm.setInt16(i * 2, value, Endian.little);
  }
  return pcm.buffer.asUint8List();
}

/// One hoot: a soft round tone that swells in, lifts and sags a little,
/// with a faint octave above for the breathy edge of an owl's call.
void _hoot(
  Float64List out,
  double at,
  double pitch,
  double level,
  double length,
) {
  double gain(double t) {
    if (t < 0.05) return level * t / 0.05;
    final fall = length - 0.09;
    if (t < fall) return level;
    if (t > length) return 0;
    return level * pow(0.0001 / level, (t - fall) / 0.09);
  }

  double frequency(double f, double t) => t < 0.06
      ? f * 0.96 + f * 0.04 * t / 0.06
      : f - f * 0.03 * (t - 0.06) / (length - 0.06);

  final first = (at * _rate).round();
  final count = ((length + 0.02) * _rate).round();
  var phase1 = 0.0;
  var phase2 = 0.0;
  for (var i = 0; i < count && first + i < out.length; i++) {
    final t = i / _rate;
    phase1 += 2 * pi * frequency(pitch, t) / _rate;
    phase2 += 2 * pi * frequency(pitch * 2, t) / _rate;
    out[first + i] += gain(t) * (sin(phase1) + 0.12 * sin(phase2));
  }
}

/// One tick: a short sine sliding from [from] to [to], struck and gone in
/// 70 ms, with the hoot's faint octave so the two sound related.
void _tick(Float64List out, double at, double from, double to, double level) {
  const length = 0.07;
  double gain(double t) =>
      t < 0.004 ? level * t / 0.004 : level * exp(-(t - 0.004) / 0.016);

  final first = (at * _rate).round();
  final count = (length * _rate).round();
  var phase1 = 0.0;
  var phase2 = 0.0;
  for (var i = 0; i < count && first + i < out.length; i++) {
    final t = i / _rate;
    final pitch = from + (to - from) * t / length;
    phase1 += 2 * pi * pitch / _rate;
    phase2 += 2 * pi * pitch * 2 / _rate;
    out[first + i] += gain(t) * (sin(phase1) + 0.12 * sin(phase2));
  }
}

/// [pcm] in a WAV file's clothes.
Uint8List _wav(Uint8List pcm) {
  final header = ByteData(44)
    ..setUint32(0, 0x52494646) // RIFF
    ..setUint32(4, 36 + pcm.length, Endian.little)
    ..setUint32(8, 0x57415645) // WAVE
    ..setUint32(12, 0x666d7420) // fmt
    ..setUint32(16, 16, Endian.little)
    ..setUint16(20, 1, Endian.little) // PCM
    ..setUint16(22, 1, Endian.little) // mono
    ..setUint32(24, _rate, Endian.little)
    ..setUint32(28, _rate * 2, Endian.little)
    ..setUint16(32, 2, Endian.little)
    ..setUint16(34, 16, Endian.little)
    ..setUint32(36, 0x64617461) // data
    ..setUint32(40, pcm.length, Endian.little);
  return Uint8List.fromList([...header.buffer.asUint8List(), ...pcm]);
}
