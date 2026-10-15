// What the gateway talks about: spaces, channels and who is in them. The
// JSON of wisetalk_core::{protocol, gateway}; fields the app doesn't use yet
// are left out.

/// Who may enter: accounts only, a whitelist, hidden from the rest.
class AccessFlags {
  const AccessFlags({
    this.authRequired = false,
    this.whitelist = false,
    this.hidden = false,
  });

  factory AccessFlags.fromJson(Map<String, dynamic>? json) => AccessFlags(
    authRequired: json?['auth_required'] as bool? ?? false,
    whitelist: json?['whitelist'] as bool? ?? false,
    hidden: json?['hidden'] as bool? ?? false,
  );

  final bool authRequired;
  final bool whitelist;
  final bool hidden;

  bool get any => authRequired || whitelist || hidden;

  AccessFlags copyWith({bool? authRequired, bool? whitelist, bool? hidden}) =>
      AccessFlags(
        authRequired: authRequired ?? this.authRequired,
        whitelist: whitelist ?? this.whitelist,
        hidden: hidden ?? this.hidden,
      );

  Map<String, dynamic> toJson() => {
    'auth_required': authRequired,
    'whitelist': whitelist,
    'hidden': hidden,
  };

  @override
  bool operator ==(Object other) =>
      other is AccessFlags &&
      other.authRequired == authRequired &&
      other.whitelist == whitelist &&
      other.hidden == hidden;

  @override
  int get hashCode => Object.hash(authRequired, whitelist, hidden);
}

class Space {
  const Space({
    required this.id,
    required this.name,
    required this.position,
    this.flags = const AccessFlags(),
    this.owner,
    this.icon,
  });

  factory Space.fromJson(Map<String, dynamic> json) => Space(
    id: json['id'] as String,
    name: json['name'] as String,
    position: json['position'] as int? ?? 0,
    flags: AccessFlags.fromJson(json['flags'] as Map<String, dynamic>?),
    owner: json['owner'] as String?,
    icon: json['icon'] as String?,
  );

  final String id;
  final String name;
  final int position;
  final AccessFlags flags;

  /// The account that manages the space and its channels, if any.
  final String? owner;
  final String? icon;
}

class AudioQuality {
  const AudioQuality({required this.bitrate, required this.stereo});

  factory AudioQuality.fromJson(Map<String, dynamic>? json) => AudioQuality(
    bitrate: json?['bitrate'] as int? ?? 64000,
    stereo: json?['stereo'] as bool? ?? false,
  );

  final int bitrate;
  final bool stereo;
}

class Channel {
  const Channel({
    required this.id,
    required this.name,
    required this.position,
    required this.audio,
    this.flags = const AccessFlags(),
    this.space,
    this.owner,
    this.icon,
    this.maxParticipants,
  });

  factory Channel.fromJson(Map<String, dynamic> json) => Channel(
    id: json['id'] as String,
    name: json['name'] as String,
    position: json['position'] as int? ?? 0,
    audio: AudioQuality.fromJson(json['audio'] as Map<String, dynamic>?),
    flags: AccessFlags.fromJson(json['flags'] as Map<String, dynamic>?),
    space: json['space'] as String?,
    owner: json['owner'] as String?,
    icon: json['icon'] as String?,
    maxParticipants: json['max_participants'] as int?,
  );

  final String id;
  final String name;
  final int position;
  final AudioQuality audio;
  final AccessFlags flags;

  /// The account that manages the channel, if any.
  final String? owner;

  /// `null` for no limit.
  final int? maxParticipants;

  /// `null` for a channel outside any space.
  final String? space;
  final String? icon;
}

/// Someone in a voice channel: one gateway connection of one device.
class Participant {
  const Participant({
    required this.session,
    required this.displayName,
    required this.device,
    required this.publicKey,
    required this.serverMuted,
    this.account,
    this.avatar,
  });

  factory Participant.fromJson(Map<String, dynamic> json) => Participant(
    session: json['session'] as String,
    displayName: json['display_name'] as String,
    device: json['device'] as String,
    publicKey: json['public_key'] as String,
    serverMuted: json['server_muted'] as bool? ?? false,
    account: json['account'] as String?,
    avatar: json['avatar'] as int?,
  );

  final String session;
  final String displayName;
  final String device;
  final String publicKey;
  final bool serverMuted;

  /// `null` for guests.
  final String? account;
  final int? avatar;
}

/// A channel as this session sees it.
class ChannelView {
  ChannelView({
    required this.channel,
    required this.locked,
    required this.permissions,
    required this.participants,
  });

  factory ChannelView.fromJson(Map<String, dynamic> json) => ChannelView(
    channel: Channel.fromJson(json['channel'] as Map<String, dynamic>),
    locked: json['locked'] as bool? ?? false,
    permissions: json['permissions'] as String? ?? '',
    participants: [
      for (final p in json['participants'] as List<dynamic>? ?? const [])
        Participant.fromJson(p as Map<String, dynamic>),
    ],
  );

  final Channel channel;

  /// Listed, but not open to this session.
  final bool locked;
  final String permissions;
  final List<Participant> participants;

  /// Whether we may do [permission] here, a name like `VIDEO`.
  bool can(String permission) =>
      permissions.split('|').any((p) => p.trim() == permission);
}

/// A device and its public key.
class DeviceKey {
  const DeviceKey({required this.device, required this.publicKey});

  factory DeviceKey.fromJson(Map<String, dynamic> json) => DeviceKey(
    device: json['device'] as String,
    publicKey: json['public_key'] as String,
  );

  final String device;
  final String publicKey;
}

/// A chat key sealed for this device, and the device that sealed it. The
/// envelope stays gateway JSON: it goes to Rust as it came.
class ChatKeyGrant {
  const ChatKeyGrant({required this.from, required this.envelope});

  factory ChatKeyGrant.fromJson(Map<String, dynamic> json) => ChatKeyGrant(
    from: DeviceKey.fromJson(json['from'] as Map<String, dynamic>),
    envelope: json['envelope'] as Map<String, dynamic>,
  );

  final DeviceKey from;
  final Map<String, dynamic> envelope;

  String get channel => envelope['channel'] as String;
  String get key => envelope['key'] as String;
}

/// A picture in a chat message, encrypted with the same key as its text.
class ChatImage {
  const ChatImage(this.json);

  /// As the server sent it: the author bound all of it to the ciphertext.
  final Map<String, dynamic> json;

  String get id => json['id'] as String;
  String get type => json['type'] as String;
  int get width => json['width'] as int;
  int get height => json['height'] as int;
}

/// One chat message. [text] is `null` until (or unless) it decrypts.
class ChatMessage {
  ChatMessage({
    required this.id,
    required this.channel,
    required this.author,
    required this.authorName,
    required this.avatar,
    required this.sealed,
    required this.image,
    required this.sentAt,
    this.text,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    id: json['id'] as String,
    channel: json['channel'] as String,
    author: json['author'] as String?,
    authorName: json['author_name'] as String,
    avatar: json['avatar'] as int?,
    sealed: json['sealed'] as Map<String, dynamic>,
    image: json['image'] == null
        ? null
        : ChatImage(json['image'] as Map<String, dynamic>),
    sentAt: DateTime.fromMillisecondsSinceEpoch(json['sent_at'] as int),
  );

  final String id;
  final String channel;

  /// The author's account; `null` for guests.
  final String? author;
  final String authorName;
  final int? avatar;

  /// The text, encrypted on the author's device; may be empty under a picture.
  final Map<String, dynamic> sealed;
  final ChatImage? image;
  final DateTime sentAt;
  String? text;

  String get key => sealed['key'] as String;
}

/// A chat as loaded: its messages and the keys sealed for this device.
class ChatHistory {
  const ChatHistory({
    required this.messages,
    required this.expiresAt,
    required this.key,
    required this.keys,
  });

  factory ChatHistory.fromJson(Map<String, dynamic> json) => ChatHistory(
    messages: [
      for (final m in json['messages'] as List<dynamic>)
        ChatMessage.fromJson(m as Map<String, dynamic>),
    ],
    expiresAt: json['expires_at'] == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(json['expires_at'] as int),
    key: json['key'] as String?,
    keys: [
      for (final k in json['keys'] as List<dynamic>)
        ChatKeyGrant.fromJson(k as Map<String, dynamic>),
    ],
  );

  final List<ChatMessage> messages;

  /// `null` while the chat is empty.
  final DateTime? expiresAt;

  /// The key new messages use; `null` until someone starts one.
  final String? key;
  final List<ChatKeyGrant> keys;
}

/// Where an account's avatar is; [version] changes with every new picture,
/// so the server lets it be cached forever.
Uri avatarUrl(Uri origin, String account, int version) => origin.replace(
  path: '/api/avatars/$account',
  queryParameters: {'v': '$version'},
);
