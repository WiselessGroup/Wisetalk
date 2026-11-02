import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wisetalk/data/api.dart';
import 'package:wisetalk/data/device.dart';
import 'package:wisetalk/data/gateway.dart';
import 'package:wisetalk/data/notifications.dart';
import 'package:wisetalk/data/servers.dart';
import 'package:wisetalk/data/session.dart';
import 'package:wisetalk/data/stay_connected.dart';
import 'package:wisetalk/data/summons.dart';
import 'package:wisetalk/src/rust/api/device.dart';
import 'package:wisetalk/src/rust/frb_generated.dart';

/// A gateway on the loopback: what the app sends, and a way to answer.
class _Server {
  _Server._(this._http);

  static Future<_Server> start() async {
    final server = _Server._(await HttpServer.bind('127.0.0.1', 0));
    server._http.listen(server._serve);
    return server;
  }

  final HttpServer _http;
  final _sockets = StreamController<WebSocket>();
  late final _next = StreamIterator(_sockets.stream);
  final _commands = StreamController<Map<String, dynamic>>();
  late final _received = StreamIterator(_commands.stream);
  WebSocket? socket;

  Uri get origin => Uri.parse('http://127.0.0.1:${_http.port}');

  Future<void> _serve(HttpRequest request) async {
    if (request.uri.path == '/api/me') {
      request.response
        ..headers.contentType = ContentType.json
        ..write(jsonEncode({'display_name': 'owl', 'id': 'owl-account'}));
      await request.response.close();
      return;
    }
    final socket = await WebSocketTransformer.upgrade(request);
    socket.listen(
      (message) =>
          _commands.add(jsonDecode(message as String) as Map<String, dynamic>),
    );
    _sockets.add(socket);
  }

  /// The next connection the app opens.
  Future<WebSocket> accepted() async {
    expect(await _next.moveNext().timeout(const Duration(seconds: 10)), isTrue);
    return socket = _next.current;
  }

  /// The type of the next command the app sends, with its data.
  Future<(String, Object?)> command() async {
    expect(
      await _received.moveNext().timeout(const Duration(seconds: 10)),
      isTrue,
    );
    return (_received.current['type'] as String, _received.current['data']);
  }

  /// The next command says the app goes to the background or comes back.
  Future<void> expectBackground(bool on) async {
    final (type, data) = await command();
    expect(type, 'set_background');
    expect(data, {'background': on});
  }

  void say(String type, Object? data) =>
      socket!.add(jsonEncode({'type': type, 'data': data}));

  Future<void> close() => _http.close(force: true);
}

Map<String, dynamic> _ready({bool background = false}) => {
  'session': 'session-1',
  'account': 'owl-account',
  'spaces': <Object>[],
  'channels': background
      ? <Object>[]
      : [
          {
            'channel': {'id': 'lobby', 'name': 'Lobby'},
            'participants': <Object>[],
          },
        ],
  if (background) 'background': true,
};

/// Waits for what the app makes of a message. It comes over a real socket, so
/// on a busy machine it may not have arrived after a pumped event queue.
Future<void> _until(bool Function() done) async {
  final deadline = DateTime.now().add(const Duration(seconds: 10));
  while (!done() && DateTime.now().isBefore(deadline)) {
    await Future<void>.delayed(const Duration(milliseconds: 5));
  }
}

void main() {
  setUpAll(() async => RustLib.init());

  test('only a resumed app is in front, and nobody before a window', () {
    expect(isInFront(null), isTrue);
    expect(isInFront(null, launchedInBackground: true), isFalse);
    expect(
      isInFront(AppLifecycleState.resumed, launchedInBackground: true),
      isTrue,
    );
  });

  test('the connection goes quiet only in the background, out of calls', () {
    expect(quietNow(staying: true, away: true, inCall: false), isTrue);
    expect(quietNow(staying: true, away: false, inCall: false), isFalse);
    expect(quietNow(staying: true, away: true, inCall: true), isFalse);
    expect(quietNow(staying: false, away: true, inCall: false), isFalse);
    // The notification shade over the app is not the background.
    expect(awayFrom(AppLifecycleState.inactive), isFalse);
    expect(awayFrom(AppLifecycleState.hidden), isTrue);
    expect(awayFrom(AppLifecycleState.paused), isTrue);
    expect(awayFrom(null), isFalse);
    expect(awayFrom(null, launchedInBackground: true), isTrue);
  });

  test('steps for phones dontkillmyapp knows, the start page otherwise', () {
    expect(stepsFor('samsung').toString(), 'https://dontkillmyapp.com/samsung');
    expect(stepsFor('Xiaomi').toString(), 'https://dontkillmyapp.com/xiaomi');
    expect(stepsFor('Fairphone').toString(), 'https://dontkillmyapp.com/');
    expect(stepsFor(null).toString(), 'https://dontkillmyapp.com/');
  });

  group('background mode', () {
    late _Server server;
    late Gateway gateway;

    setUp(() async {
      server = await _Server.start();
      gateway = Gateway(
        Session(
          server: SavedServer(origin: server.origin, name: 'Wiseless'),
          me: const Me(displayName: 'owl', id: 'owl-account'),
          token: 'token',
        ),
        LocalDevice('phone', Device.generate()),
      );
    });

    tearDown(() async {
      gateway.dispose();
      await server.close();
    });

    test('reconnects quietly and comes back with everything', () async {
      final heard = <String>[];
      gateway.events.listen((event) => heard.add(event.type));
      unawaited(gateway.connect());
      await server.accepted();
      expect((await server.command()).$1, 'hello');
      server.say('ready', _ready());
      await _until(() => gateway.channels.isNotEmpty);
      expect(gateway.channels.single.channel.name, 'Lobby');

      gateway.setBackground(true);
      await server.expectBackground(true);

      // The phone changed networks: a new connection, quiet from the start.
      gateway.networkChanged(true);
      await server.accepted();
      await server.expectBackground(true);
      expect((await server.command()).$1, 'hello');
      server.say('ready', _ready(background: true));
      await _until(() => gateway.status == GatewayStatus.ready);
      expect(gateway.status, GatewayStatus.ready);
      // The small ready empties nothing and reaches nobody else.
      expect(gateway.channels.single.channel.name, 'Lobby');
      expect(heard, ['ready']);

      server.say('summoned', {
        'channel': 'lobby',
        'from': 'boss',
        'channel_name': 'Lobby',
      });
      await _until(() => heard.length == 2);
      expect(heard, ['ready', 'summoned']);

      gateway.setBackground(false);
      await server.expectBackground(false);
      server.say('ready', _ready());
      await _until(() => heard.length == 3);
      expect(heard, ['ready', 'summoned', 'ready']);
    });

    test('an older server that can\'t read it changes nothing', () async {
      final heard = <String>[];
      gateway.events.listen((event) => heard.add(event.type));
      unawaited(gateway.connect());
      await server.accepted();
      expect((await server.command()).$1, 'hello');
      server.say('ready', _ready());
      await _until(() => gateway.channels.isNotEmpty);

      gateway.setBackground(true);
      expect((await server.command()).$1, 'set_background');
      server.say('error', {
        'code': 'protocol_mismatch',
        'message': 'unreadable command',
        'problem': {'key': 'unreadable_command'},
      });
      // Messages keep their order: this one arriving means the error did.
      server.say('summoned', {'channel': 'lobby', 'from': 'boss'});
      await _until(() => heard.contains('summoned'));
      expect(gateway.error, isNull);

      // Not asked again: the next thing the server hears is a summon.
      gateway.setBackground(false);
      gateway.send('summon', {'channel': 'lobby', 'account': 'boss'});
      expect((await server.command()).$1, 'summon');
    });
  });

  test('a summons names its channel, from the server or the list', () {
    final gateway = Gateway(
      Session(
        server: SavedServer(
          origin: Uri.parse('https://talk.example'),
          name: 'Example',
        ),
        me: const Me(displayName: 'owl', id: 'owl-account'),
        token: 'token',
      ),
      LocalDevice('phone', Device.generate()),
    );
    addTearDown(gateway.dispose);
    expect(
      summonedChannelName(
        {'channel': 'lobby', 'channel_name': 'Lobby'},
        gateway,
        'a channel',
      ),
      'Lobby',
    );
    // Older servers don't name it, and the list is empty here.
    expect(
      summonedChannelName({'channel': 'lobby'}, gateway, 'a channel'),
      'a channel',
    );
  });
}
