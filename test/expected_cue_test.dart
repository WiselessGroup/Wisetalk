import 'package:flutter_test/flutter_test.dart';
import 'package:wisetalk/data/shortcuts.dart';
import 'package:wisetalk/data/sounds.dart';
import 'package:wisetalk/data/voice.dart';

void main() {
  Cue cue(
    CallAction action, {
    bool away = false,
    bool muted = false,
    bool serverMuted = false,
  }) => expectedCue(action, away: away, muted: muted, serverMuted: serverMuted);

  test('the tick played at once says what the shortcut will do', () {
    expect(cue(CallAction.toggleMute), Cue.mute);
    expect(cue(CallAction.toggleMute, muted: true), Cue.unmute);
    expect(cue(CallAction.unmute, muted: true), Cue.unmute);
    expect(cue(CallAction.mute), Cue.mute);
    expect(cue(CallAction.toggleAway), Cue.away);
    expect(cue(CallAction.toggleAway, away: true, muted: true), Cue.back);
  });

  test('away, turning the microphone on comes back; off stays off', () {
    expect(cue(CallAction.toggleMute, away: true, muted: true), Cue.back);
    expect(cue(CallAction.unmute, away: true, muted: true), Cue.back);
    expect(cue(CallAction.mute, away: true, muted: true), Cue.mute);
  });

  test('a server mute refuses turning the microphone on', () {
    expect(
      cue(CallAction.toggleMute, muted: true, serverMuted: true),
      Cue.mute,
    );
    expect(cue(CallAction.unmute, muted: true, serverMuted: true), Cue.mute);
  });
}
