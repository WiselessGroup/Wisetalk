// What the gateway talks about: spaces, channels and who is in them. The
// JSON of wisetalk_core::{protocol, gateway}; fields the app doesn't use yet
// are left out.

class Space {
  const Space({
    required this.id,
    required this.name,
    required this.position,
    this.icon,
  });

  factory Space.fromJson(Map<String, dynamic> json) => Space(
    id: json['id'] as String,
    name: json['name'] as String,
    position: json['position'] as int? ?? 0,
    icon: json['icon'] as String?,
  );

  final String id;
  final String name;
  final int position;
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
    this.space,
    this.icon,
  });

  factory Channel.fromJson(Map<String, dynamic> json) => Channel(
    id: json['id'] as String,
    name: json['name'] as String,
    position: json['position'] as int? ?? 0,
    audio: AudioQuality.fromJson(json['audio'] as Map<String, dynamic>?),
    space: json['space'] as String?,
    icon: json['icon'] as String?,
  );

  final String id;
  final String name;
  final int position;
  final AudioQuality audio;

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
