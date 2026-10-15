import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wisetalk/data/notifications.dart';

void main() {
  test('only a resumed app is in front', () {
    expect(isInFront(AppLifecycleState.resumed), isTrue);
    // GNOME on Wayland: another window focused, or this one minimized.
    expect(isInFront(AppLifecycleState.inactive), isFalse);
    expect(isInFront(AppLifecycleState.hidden), isFalse);
    expect(isInFront(AppLifecycleState.paused), isFalse);
    expect(isInFront(AppLifecycleState.detached), isFalse);
    // Not shown yet: just started by the person.
    expect(isInFront(null), isTrue);
  });

  testWidgets('whoever asks late sees the current state', (tester) async {
    // The window went to the background before anyone asked, as when a
    // new connection's workspace is built while Wisetalk is behind
    // another window: no change comes after that.
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    expect(appInFront, isFalse);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    expect(appInFront, isTrue);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    expect(appInFront, isFalse);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
  });
}
