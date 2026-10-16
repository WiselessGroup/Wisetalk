import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:wisetalk/data/notifications.dart';
import 'package:wisetalk/data/unified_push.dart';

void main() {
  test('a summons push reads as the web worker reads it', () {
    final push = SummonPush.parse(
      utf8.encode(
        jsonEncode({
          'caller': 'Ёжик',
          'channelId': '0190a3c4-1111-7000-8000-000000000001',
          'channelName': '大廳',
          // Fields a newer server adds are fine.
          'sentAt': 1760000000,
        }),
      ),
    );
    expect(push, isNotNull);
    expect(push!.caller, 'Ёжик');
    expect(push.channel, '0190a3c4-1111-7000-8000-000000000001');
    expect(push.channelName, '大廳');
  });

  test('anything else is not a summons', () {
    SummonPush? parse(Object? json) =>
        SummonPush.parse(utf8.encode(jsonEncode(json)));
    expect(parse({'caller': 'A', 'channelId': 'c'}), isNull);
    expect(parse({'caller': 'A', 'channelId': 1, 'channelName': 'C'}), isNull);
    expect(parse(['A', 'c', 'C']), isNull);
    expect(parse(null), isNull);
    expect(SummonPush.parse(utf8.encode('not json')), isNull);
    expect(SummonPush.parse([0xff, 0xfe, 0x00]), isNull);
    expect(SummonPush.parse(const []), isNull);
  });

  test('the subscription is what the server takes from a browser', () {
    expect(
      pushSubscriptionJson(
        endpoint: 'https://ntfy.example/upAbc?up=1',
        p256dh: 'BPk-key',
        auth: 'c2VjcmV0',
      ),
      {
        'endpoint': 'https://ntfy.example/upAbc?up=1',
        'keys': {'p256dh': 'BPk-key', 'auth': 'c2VjcmV0'},
      },
    );
  });

  test('distributors have names people know', () {
    expect(distributorName('io.heckel.ntfy'), 'ntfy');
    expect(distributorName('org.unifiedpush.distributor.nextpush'), 'NextPush');
    expect(distributorName('com.example.pushy'), 'pushy');
  });

  test('a summons notification knows its server', () {
    final server = Uri.parse('https://talk.example.com');
    final target = SummonTarget('channel-1', server: server);
    final back = NotificationTarget.parse(target.payload) as SummonTarget;
    expect(back.channel, 'channel-1');
    expect(back.server, server);

    // Notifications from before name the channel only.
    final old = NotificationTarget.parse('summon:channel-2') as SummonTarget;
    expect(old.channel, 'channel-2');
    expect(old.server, isNull);
    expect(NotificationTarget.parse('chat:channel-3'), isA<ChatTarget>());
  });
}
