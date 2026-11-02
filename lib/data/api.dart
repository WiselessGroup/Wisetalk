// The server's HTTP API, as much of it as the app uses so far. Bodies are
// the JSON of wisetalk_core::api.

import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../l10n/app_localizations.dart';
import 'language.dart';
import 'problem.dart';
import 'protocol.dart';

/// Who a session belongs to (`GET /api/me`).
class Me {
  const Me({
    required this.displayName,
    this.id,
    this.username,
    this.role,
    this.avatar,
  });

  factory Me.fromJson(Map<String, dynamic> json) => Me(
    displayName: json['display_name'] as String,
    id: json['id'] as String?,
    username: json['username'] as String?,
    role: json['role'] as String?,
    avatar: json['avatar'] as int?,
  );

  final String displayName;

  /// `null` for guests, like [username] and [role].
  final String? id;
  final String? username;
  final String? role;
  final int? avatar;

  bool get isGuest => id == null;
}

/// An account as the server's people list shows it (`GET /api/accounts`).
class AccountSummary {
  const AccountSummary({
    required this.id,
    required this.username,
    required this.displayName,
    required this.role,
    this.avatar,
  });

  factory AccountSummary.fromJson(Map<String, dynamic> json) => AccountSummary(
    id: json['id'] as String,
    username: json['username'] as String,
    displayName: json['display_name'] as String,
    role: json['role'] as String,
    avatar: json['avatar'] as int?,
  );

  final String id;
  final String username;
  final String displayName;
  final String role;
  final int? avatar;
}

/// Server roles from the most to the least powerful; someone may moderate
/// only those ranked below them.
const roleRank = {
  'owner': 4,
  'admin': 3,
  'moderator': 2,
  'member': 1,
  'guest': 0,
};

/// How a server presents itself, set by its admins. Every field is optional.
class Branding {
  const Branding({this.community, this.tagline, this.loginLabel});

  factory Branding.fromJson(Map<String, dynamic>? json) => Branding(
    community: json?['community'] as String?,
    tagline: json?['tagline'] as String?,
    loginLabel: json?['login_label'] as String?,
  );

  final String? community;
  final String? tagline;
  final String? loginLabel;

  /// The same fallbacks as the web client's `lib/branding.ts`.
  String taglineText(AppLocalizations texts) =>
      tagline ?? texts.brandingTagline;
  String signInText(AppLocalizations texts) => loginLabel == null
      ? texts.brandingSignIn
      : texts.brandingSignInWith(loginLabel!);
  String? hostedByText(AppLocalizations texts) =>
      community == null ? null : texts.brandingHostedBy(community!);
}

/// `GET /api/server`: what a server is, asked before signing in.
class ServerInfo {
  const ServerInfo({
    required this.guestsOpen,
    required this.accounts,
    required this.version,
    required this.protocol,
    required this.branding,
  });

  factory ServerInfo.fromJson(Map<String, dynamic> json) => ServerInfo(
    guestsOpen: json['guests_open'] as bool? ?? false,
    accounts: json['accounts'] as bool? ?? false,
    version: json['version'] as String? ?? '',
    protocol: json['protocol'] as int? ?? 0,
    branding: Branding.fromJson(json['branding'] as Map<String, dynamic>?),
  );

  final bool guestsOpen;
  final bool accounts;
  final String version;
  final int protocol;
  final Branding branding;
}

/// A new session: its bearer token and who it belongs to.
class SignedIn {
  const SignedIn({required this.token, required this.me, this.passport});

  factory SignedIn.fromJson(Map<String, dynamic> json) => SignedIn(
    token: json['token'] as String,
    me: Me.fromJson(json['me'] as Map<String, dynamic>),
    passport: json['passport'] as String?,
  );

  final String token;
  final Me me;

  /// A guest's new passport (WLK-49), kept with the server past sign-out
  /// and sent at the next guest sign-in, so a guest the server knows and
  /// never kicked is not held back by the limits for their address. Only
  /// with a first sign-in; a known passport gets none.
  final String? passport;
}

class GuestChallenge {
  const GuestChallenge(this.challenge, this.difficulty);

  final String challenge;
  final int difficulty;
}

/// The app's latest release, as the server finds it (`GET /api/downloads`).
class Downloads {
  const Downloads({required this.version, required this.files});

  factory Downloads.fromJson(Map<String, dynamic> json) => Downloads(
    version: json['version'] as String?,
    files: [
      for (final f in json['files'] as List<dynamic>)
        (
          platform: (f as Map<String, dynamic>)['platform'] as String,
          url: f['url'] as String,
        ),
    ],
  );

  /// `null` while there's no release.
  final String? version;
  final List<({String platform, String url})> files;
}

/// A refusal from the server, with the message it gave for people.
class ApiException implements Exception {
  const ApiException(this.status, this.message);

  final int status;
  final String message;

  bool get unauthorized => status == 401;

  @override
  String toString() => message;
}

/// Talks to one server, as one session when [token] is set.
class Api {
  Api(this.origin, {this.token, http.Client? client})
    : _client = client ?? http.Client();

  final Uri origin;
  final String? token;
  final http.Client _client;

  Uri _url(String path, [Map<String, String>? query]) =>
      origin.replace(path: '/api$path', queryParameters: query);

  Map<String, String> get _headers => {
    'accept': 'application/json',
    'content-type': 'application/json',
    if (token != null) 'authorization': 'Bearer $token',
  };

  Future<dynamic> _send(
    String method,
    String path, [
    Object? body,
    Map<String, String>? query,
  ]) async {
    final request = http.Request(method, _url(path, query))
      ..headers.addAll(_headers);
    if (body != null) request.body = jsonEncode(body);
    final http.Response response;
    try {
      response = await http.Response.fromStream(
        await _client.send(request).timeout(const Duration(seconds: 15)),
      );
    } on Exception {
      throw ApiException(0, appTexts.apiUnreachableCheck);
    }
    if (response.statusCode >= 400) {
      throw ApiException(response.statusCode, _message(response));
    }
    final text = utf8.decode(response.bodyBytes);
    if (text.isEmpty) return null;
    try {
      return jsonDecode(text);
    } on FormatException {
      throw ApiException(0, appTexts.apiNotWisetalk);
    }
  }

  /// What the server said went wrong, for people, in their language when
  /// it names the problem (WLK-14).
  String _message(http.Response response) {
    try {
      final json = jsonDecode(utf8.decode(response.bodyBytes));
      if (json is Map<String, dynamic> && json['message'] is String) {
        return problemText(
          appTexts,
          json['problem'],
          json['message'] as String,
          code: json['error'] as String?,
        );
      }
    } on FormatException {
      // Not one of our errors: a proxy's page, say.
    }
    return appTexts.apiRefused(response.statusCode);
  }

  Future<ServerInfo> server() async {
    final json = await _send('GET', '/server');
    if (json is! Map<String, dynamic> || !json.containsKey('guests_open')) {
      throw ApiException(0, appTexts.apiNotWisetalk);
    }
    return ServerInfo.fromJson(json);
  }

  Future<Me> me() async =>
      Me.fromJson(await _send('GET', '/me') as Map<String, dynamic>);

  /// Where the browser goes to sign in with an account; see [exchange].
  Uri loginUrl({
    required Uri redirect,
    required String challenge,
    required String state,
  }) => _url('/auth/login', {
    'redirect_uri': redirect.toString(),
    'code_challenge': challenge,
    'state': state,
  });

  /// Trades the code the browser brought back for a session.
  Future<SignedIn> exchange({
    required String code,
    required String verifier,
    required Uri redirect,
  }) async => SignedIn.fromJson(
    await _send('POST', '/auth/token', {
      'code': code,
      'code_verifier': verifier,
      'redirect_uri': redirect.toString(),
    }) as Map<String, dynamic>,
  );

  Future<GuestChallenge> guestChallenge() async {
    final json =
        await _send('POST', '/auth/guest/challenge') as Map<String, dynamic>;
    return GuestChallenge(
      json['challenge'] as String,
      json['difficulty'] as int,
    );
  }

  /// [passport] is the one an earlier guest sign-in here handed out, if any.
  Future<SignedIn> signInAsGuest(
    String name,
    GuestChallenge challenge,
    int nonce, {
    String? passport,
  }) async => SignedIn.fromJson(
    await _send('POST', '/auth/guest/token', {
      'display_name': name,
      'proof': {'challenge': challenge.challenge, 'nonce': nonce},
      'passport': ?passport,
    }) as Map<String, dynamic>,
  );

  Future<void> signOut() => _send('POST', '/auth/logout');

  Future<Downloads> downloads() async => Downloads.fromJson(
    await _send('GET', '/downloads') as Map<String, dynamic>,
  );

  /// A channel's chat with the keys sealed for [device] (this one's).
  Future<ChatHistory> chatHistory(String channel, String device) async =>
      ChatHistory.fromJson(
        await _send('GET', '/channels/$channel/messages', null, {
          'device': device,
        }) as Map<String, dynamic>,
      );

  /// Every device a new chat key has to be sealed for.
  Future<List<DeviceKey>> chatDevices(String channel) async {
    final json = await _send(
      'GET',
      '/channels/$channel/chat-devices',
    ) as Map<String, dynamic>;
    return [
      for (final d in json['devices'] as List<dynamic>)
        DeviceKey.fromJson(d as Map<String, dynamic>),
    ];
  }

  /// Uploads an encrypted chat picture before the message that carries it.
  Future<void> uploadChatImage(
    String channel,
    String image,
    Uint8List ciphertext,
  ) async {
    final http.Response response;
    try {
      response = await _client
          .put(
            _url('/channels/$channel/chat-images/$image'),
            headers: {
              'content-type': 'application/octet-stream',
              if (token != null) 'authorization': 'Bearer $token',
            },
            body: ciphertext,
          )
          .timeout(const Duration(minutes: 2));
    } on Exception {
      throw ApiException(0, appTexts.apiUnreachable);
    }
    if (response.statusCode >= 400) {
      throw ApiException(response.statusCode, _message(response));
    }
  }

  Future<Uint8List> downloadChatImage(String channel, String image) async {
    final http.Response response;
    try {
      response = await _client
          .get(
            _url('/channels/$channel/chat-images/$image'),
            headers: {if (token != null) 'authorization': 'Bearer $token'},
          )
          .timeout(const Duration(minutes: 2));
    } on Exception {
      throw ApiException(0, appTexts.apiUnreachable);
    }
    if (response.statusCode >= 400) {
      throw ApiException(response.statusCode, _message(response));
    }
    return response.bodyBytes;
  }

  // --- Managing the server, for whoever may ---------------------------

  Future<List<AccountSummary>> accounts() async => [
    for (final a in await _send('GET', '/accounts') as List<dynamic>)
      AccountSummary.fromJson(a as Map<String, dynamic>),
  ];

  /// Makes an account an admin, or a member again (owners only).
  Future<void> setRole(String account, String role) =>
      _send('PUT', '/accounts/$account/role', {'role': role});

  Future<void> ban(String account) =>
      _send('POST', '/bans', {'account': account});

  /// Removes a guest and blocks guests from their address for a day.
  Future<void> banGuest(String session) =>
      _send('POST', '/guest-bans', {'session': session});

  Future<void> createChannel(String name, {String? space}) =>
      _send('POST', '/channels', {'name': name, 'space': space});

  Future<void> createSpace(String name) =>
      _send('POST', '/spaces', {'name': name});

  /// Changes the given fields of a channel; `owner` and `space` may be
  /// `null` to clear them, so they are sent only when in [fields].
  Future<void> updateChannel(String channel, Map<String, dynamic> fields) =>
      _send('PATCH', '/channels/$channel', fields);

  Future<void> updateSpace(String space, Map<String, dynamic> fields) =>
      _send('PATCH', '/spaces/$space', fields);

  Future<void> deleteChannel(String channel) =>
      _send('DELETE', '/channels/$channel');

  Future<void> deleteSpace(String space) => _send('DELETE', '/spaces/$space');

  /// The whole order of the channel list: spaces with their channels, and
  /// channels outside any space.
  Future<void> setLayout(List<Map<String, dynamic>> items) =>
      _send('PUT', '/layout', {'items': items});

  // --- Me -----------------------------------------------------------------

  /// Sets the account's picture: PNG, JPEG or WebP, at most 256 KB. Returns
  /// the new version.
  Future<int> setAvatar(Uint8List bytes, String contentType) async {
    final request = http.Request('PUT', _url('/me/avatar'))
      ..headers.addAll({..._headers, 'content-type': contentType})
      ..bodyBytes = bytes;
    final http.Response response;
    try {
      response = await http.Response.fromStream(
        await _client.send(request).timeout(const Duration(seconds: 30)),
      );
    } on Exception {
      throw ApiException(0, appTexts.apiUnreachable);
    }
    if (response.statusCode >= 400) {
      throw ApiException(response.statusCode, _message(response));
    }
    final json = jsonDecode(utf8.decode(response.bodyBytes));
    return (json as Map<String, dynamic>)['avatar'] as int;
  }

  Future<void> removeAvatar() => _send('DELETE', '/me/avatar');

  /// Whether others may summon this account.
  Future<bool> allowsSummons() async {
    final json = await _send('GET', '/me/settings') as Map<String, dynamic>;
    return json['allow_summons'] as bool? ?? true;
  }

  Future<void> setAllowSummons(bool allow) =>
      _send('PUT', '/me/settings', {'allow_summons': allow});

  /// The server's VAPID public key (base64url), which push services check
  /// its pushes against; `null` when the server sends no pushes.
  Future<String?> pushKey() async {
    final json = await _send('GET', '/push') as Map<String, dynamic>;
    return json['public_key'] as String?;
  }

  /// Has the server push summons to [subscription] (see
  /// `pushSubscriptionJson`), for accounts only.
  Future<void> subscribePush(Map<String, dynamic> subscription) =>
      _send('POST', '/push/subscriptions', subscription);

  /// Stops the pushes to [endpoint].
  Future<void> unsubscribePush(String endpoint) =>
      _send('DELETE', '/push/subscriptions', {'endpoint': endpoint});

  /// Accounts matching [query] that could come into [channel] when summoned.
  Future<List<AccountSummary>> summonable(String channel, String query) async =>
      [
        for (final a in await _send(
          'GET',
          '/channels/$channel/summonable',
          null,
          {'q': query},
        ) as List<dynamic>)
          AccountSummary.fromJson(a as Map<String, dynamic>),
      ];

  /// A key that lets someone into a restricted channel: once used, it lets
  /// anyone in for 10 minutes; unused, it lasts a day.
  Future<String> createInvite(String channel) async {
    final json = await _send(
      'POST',
      '/channels/$channel/invites',
    ) as Map<String, dynamic>;
    return json['token'] as String;
  }
}
