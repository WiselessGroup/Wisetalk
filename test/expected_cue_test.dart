import 'package:flutter_test/flutter_test.dart';
import 'package:wisetalk/data/protocol.dart';
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

  test('the sleepy owl hoots for others stepping away and back', () {
    Participant owl({required bool away, bool muted = false}) => Participant(
      session: 'owl',
      displayName: 'Owl',
      device: 'd',
      publicKey: 'k',
      serverMuted: muted,
      away: away,
    );
    final away = <String>{};
    expect(awayCue(away, owl(away: true), me: 'me'), Cue.asleep);
    expect(awayCue(away, owl(away: true, muted: true), me: 'me'), isNull);
    expect(awayCue(away, owl(away: false), me: 'me'), Cue.awake);
    expect(away, isEmpty);
  });

  test('my own Away gets no owl', () {
    const me = Participant(
      session: 'me',
      displayName: 'Me',
      device: 'd',
      publicKey: 'k',
      serverMuted: false,
      away: true,
    );
    expect(awayCue(<String>{}, me, me: 'me'), isNull);
  });
}
