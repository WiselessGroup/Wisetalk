import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wisetalk/data/address.dart';
import 'package:wisetalk/data/secrets.dart';
import 'package:wisetalk/data/servers.dart';
import 'package:wisetalk/main.dart';
import 'package:wisetalk/src/rust/frb_generated.dart';

void main() {
  setUpAll(() async => RustLib.init());

  test('addresses become server origins', () {
    expect(
      parseServerAddress('talk.example.com').toString(),
      'https://talk.example.com',
    );
    expect(
      parseServerAddress(' https://talk.example.com/ ').toString(),
      'https://talk.example.com',
    );
    expect(
      parseServerAddress('localhost:8080').toString(),
      'http://localhost:8080',
    );
    expect(parseServerAddress('http://talk.example.com'), isNull);
    expect(parseServerAddress('talk.example.com/rooms'), isNull);
    expect(parseServerAddress('https://me@talk.example.com'), isNull);
    expect(parseServerAddress(''), isNull);
  });

  test('removing a server forgets its token and device key', () async {
    final secrets = MemorySecrets();
    final container = ProviderContainer(
      overrides: [secretsProvider.overrideWithValue(secrets)],
    );
    addTearDown(container.dispose);
    final servers = container.read(serversProvider.notifier);
    await container.read(serversProvider.future);
    final a = Uri.parse('https://a.example');
    final b = Uri.parse('https://b.example');
    await servers.add(SavedServer(origin: a, name: 'A'));
    await servers.add(SavedServer(origin: b, name: 'B'));
    await secrets.write(tokenKey(a), 'token-a');
    await secrets.write(deviceKey(a), 'device-a');
    expect(container.read(serversProvider).value!.current, b);

    await servers.remove(a);
    final now = container.read(serversProvider).value!;
    expect(now.list.map((s) => s.name), ['B']);
    expect(now.current, b);
    expect(secrets.values.containsKey(tokenKey(a)), isFalse);
    expect(secrets.values.containsKey(deviceKey(a)), isFalse);
  });

  testWidgets('a first start asks for a server, with nothing filled in', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [secretsProvider.overrideWithValue(MemorySecrets())],
        child: const WisetalkApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Which server is your community on?'), findsOneWidget);
    expect(find.text('talk.wiseless.net'), findsNothing);
  });
}
