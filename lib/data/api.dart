// The server's HTTP API, as much of it as the app uses so far. Bodies are
// the JSON of wisetalk_core::api.

import 'dart:convert';

import 'package:http/http.dart' as http;

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
  String get taglineText =>
      tagline ?? 'Voice and video chat for your community';
  String get signInText =>
      loginLabel == null ? 'Sign In' : 'Sign In with $loginLabel';
  String? get hostedByText =>
      community == null ? null : 'Hosted by $community.';
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
  const SignedIn({required this.token, required this.me});

  factory SignedIn.fromJson(Map<String, dynamic> json) => SignedIn(
    token: json['token'] as String,
    me: Me.fromJson(json['me'] as Map<String, dynamic>),
  );

  final String token;
  final Me me;
}

class GuestChallenge {
  const GuestChallenge(this.challenge, this.difficulty);

  final String challenge;
  final int difficulty;
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

  Future<dynamic> _send(String method, String path, [Object? body]) async {
    final request = http.Request(method, _url(path))..headers.addAll(_headers);
    if (body != null) request.body = jsonEncode(body);
    final http.Response response;
    try {
      response = await http.Response.fromStream(
        await _client.send(request).timeout(const Duration(seconds: 15)),
      );
    } on Exception {
      throw const ApiException(
        0,
        "Can't reach the server. Check the address and your connection.",
      );
    }
    final text = utf8.decode(response.bodyBytes);
    if (response.statusCode >= 400) {
      String message = 'The server said no (${response.statusCode}).';
      try {
        message =
            (jsonDecode(text) as Map<String, dynamic>)['message'] as String? ??
            message;
      } on FormatException {
        // Not one of our errors: a proxy's page, say.
      }
      throw ApiException(response.statusCode, message);
    }
    if (text.isEmpty) return null;
    try {
      return jsonDecode(text);
    } on FormatException {
      throw const ApiException(0, "That doesn't look like a Wisetalk server.");
    }
  }

  Future<ServerInfo> server() async {
    final json = await _send('GET', '/server');
    if (json is! Map<String, dynamic> || !json.containsKey('guests_open')) {
      throw const ApiException(0, "That doesn't look like a Wisetalk server.");
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

  Future<SignedIn> signInAsGuest(
    String name,
    GuestChallenge challenge,
    int nonce,
  ) async => SignedIn.fromJson(
    await _send('POST', '/auth/guest/token', {
      'display_name': name,
      'proof': {'challenge': challenge.challenge, 'nonce': nonce},
    }) as Map<String, dynamic>,
  );

  Future<void> signOut() => _send('POST', '/auth/logout');
}
