// What people do with the channel list besides joining: the menus of a
// person, a channel and a space, inviting, summoning, and the managing
// that admins, owners and moderators may do. The web client's workspace
// menus (Workspace.svelte), without its whitelist and permission editors.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/api.dart';
import '../data/chat.dart';
import '../data/gateway.dart';
import '../data/preferences.dart';
import '../data/protocol.dart';
import '../data/voice.dart';
import '../src/rust/api/text.dart';
import '../theme.dart';
import 'common.dart';
import 'settings_sheet.dart';

/// Where the menus act, and how they tell the person what happened.
class Manager {
  Manager({
    required this.gateway,
    required this.voice,
    required this.chats,
    required this.preferences,
    required this.toast,
    required this.openSettings,
  });

  final Gateway gateway;
  final Voice voice;
  final Chats chats;
  final Preferences preferences;
  final void Function(String) toast;
  final VoidCallback openSettings;

  Api get api => gateway.session.api;
  List<AccountSummary> _accounts = [];

  Space? spaceOf(Channel channel) =>
      gateway.spaces.where((s) => s.id == channel.space).firstOrNull;

  /// Runs a server call; says [done] when it worked, the server's reason
  /// when not.
  Future<void> _run(Future<void> Function() call, [String? done]) async {
    try {
      await call();
      if (done != null) toast(done);
    } on ApiException catch (e) {
      toast(e.message);
    }
  }

  Future<void> _loadAccounts() async {
    try {
      _accounts = await api.accounts();
    } on ApiException {
      // Not allowed or offline: the menu goes without the account items.
    }
  }

  // --- Menus ---------------------------------------------------------------

  Future<void> _menu(
    BuildContext context,
    Offset at,
    List<PopupMenuEntry<VoidCallback>> items,
  ) async {
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final action = await showMenu<VoidCallback>(
      context: context,
      position: RelativeRect.fromRect(
        at & const Size(1, 1),
        Offset.zero & overlay.size,
      ),
      items: items,
    );
    action?.call();
  }

  PopupMenuEntry<VoidCallback> _header(String title, [String? detail]) =>
      _HeaderEntry(title: title, detail: detail);

  PopupMenuEntry<VoidCallback> _item(
    BuildContext context,
    String label,
    VoidCallback action, {
    bool danger = false,
  }) => PopupMenuItem(
    value: action,
    child: Text(
      label,
      style: danger ? TextStyle(color: context.palette.error) : null,
    ),
  );

  /// Someone in a channel: how loud they are for me, and what moderators
  /// and admins may do to them.
  Future<void> personMenu(
    BuildContext context,
    Offset at,
    ChannelView view,
    Participant person,
  ) async {
    final self = person.session == gateway.sessionId;
    if (gateway.isAdmin && !self) await _loadAccounts();
    if (!context.mounted) return;
    final key = personKey(person);
    final channel = view.channel;
    final space = spaceOf(channel);
    final target = _accounts.where((a) => a.id == person.account).firstOrNull;
    final myRank = roleRank[gateway.role] ?? 0;
    final name = person.displayName;
    final items = <PopupMenuEntry<VoidCallback>>[
      _header(self ? '$name (you)' : name),
      if (self)
        _item(context, 'Audio and Video Settings…', openSettings)
      else ...[
        _VolumeEntry(preferences: preferences, person: person),
        _item(
          context,
          preferences.silenced.contains(key) ? 'Unmute for Me' : 'Mute for Me',
          () {
            if (!preferences.silenced.remove(key)) {
              preferences.silenced.add(key);
            }
            preferences.changed();
          },
        ),
      ],
      if (!self && voice.channel == channel.id && view.can('MODERATE')) ...[
        const PopupMenuDivider(),
        _item(
          context,
          person.serverMuted ? 'Lift Server Mute' : 'Server Mute',
          () => voice.serverMute(person.session, muted: !person.serverMuted),
        ),
        _item(
          context,
          'Kick from Channel',
          () => voice.kick(person.session),
          danger: true,
        ),
      ],
      if (!self && gateway.isAdmin && person.account != null) ...[
        const PopupMenuDivider(),
        _ownerItem(
          context,
          name,
          person.account!,
          channel.name,
          channel.owner,
          (owner) => api.updateChannel(channel.id, {'owner': owner}),
        ),
        if (space != null)
          _ownerItem(
            context,
            name,
            person.account!,
            space.name,
            space.owner,
            (owner) => api.updateSpace(space.id, {'owner': owner}),
          ),
        if (target != null &&
            myRank > roleRank['admin']! &&
            target.role != 'owner')
          target.role == 'admin'
              ? _item(
                  context,
                  'Remove Server Admin',
                  () => _run(
                    () => api.setRole(target.id, 'member'),
                    '$name is now a member.',
                  ),
                )
              : _item(
                  context,
                  'Make Server Admin',
                  () => _run(
                    () => api.setRole(target.id, 'admin'),
                    '$name is now a server admin.',
                  ),
                ),
        if (target == null || myRank > (roleRank[target.role] ?? 0))
          _item(context, 'Ban from Server…', () async {
            if (await confirm(
              context,
              title: 'Ban $name?',
              message:
                  'Ban $name from this server? Their sessions end right away.',
              action: 'Ban',
            )) {
              await _run(() => api.ban(person.account!), '$name is banned.');
            }
          }, danger: true),
      ],
      if (!self && gateway.isAdmin && person.account == null) ...[
        const PopupMenuDivider(),
        _item(context, 'Ban Guest for a Day…', () async {
          if (await confirm(
            context,
            title: 'Ban $name?',
            message:
                'Remove $name and block guests from their address for a day?',
            action: 'Ban',
          )) {
            await _run(
              () => api.banGuest(person.session),
              '$name is out; their address is blocked for a day.',
            );
          }
        }, danger: true),
      ],
      const PopupMenuDivider(),
      _header('Device key', fingerprint(publicKey: person.publicKey)),
    ];
    await _menu(context, at, items);
  }

  PopupMenuEntry<VoidCallback> _ownerItem(
    BuildContext context,
    String name,
    String account,
    String place,
    String? owner,
    Future<void> Function(String?) set,
  ) => owner == account
      ? _item(
          context,
          'Remove as Owner of $place',
          () => _run(() => set(null), '$place has no owner now.'),
        )
      : _item(
          context,
          'Make Owner of $place',
          () => _run(() => set(account), '$name now owns $place.'),
        );

  Future<void> channelMenu(
    BuildContext context,
    Offset at,
    ChannelView view,
  ) async {
    final channel = view.channel;
    final here = voice.channel == channel.id;
    final audio = channel.audio;
    await _menu(context, at, [
      _header(
        channel.name,
        'Audio up to ${audio.bitrate ~/ 1000} kbps, '
        '${audio.stereo ? 'stereo' : 'mono'}',
      ),
      if (here) ...[
        _item(context, 'Leave', voice.leave),
        _item(context, 'Copy Invite Link', () => copyInvite(view)),
      ] else if (!view.locked)
        _item(context, 'Join', () => voice.join(channel.id)),
      if (!view.locked)
        _item(context, 'Open Chat', () => unawaited(chats.show(channel.id))),
      if (view.can('MANAGE'))
        _item(
          context,
          'Channel Settings…',
          () => showSettingsSheet<void>(
            context,
            builder: (_) => ChannelSettingsDialog(manager: this, view: view),
          ),
        ),
      if (gateway.isAdmin) ..._moves(context, channel.id),
    ]);
  }

  Future<void> spaceMenu(BuildContext context, Offset at, Space space) async {
    if (!gateway.managesSpace(space)) return;
    await _menu(context, at, [
      _header(space.name),
      _item(
        context,
        'New Channel in Space…',
        () => showSettingsSheet<void>(
          context,
          builder: (_) => CreateDialog(manager: this, space: space.id),
        ),
      ),
      _item(
        context,
        'Space Settings…',
        () => showSettingsSheet<void>(
          context,
          builder: (_) => SpaceSettingsDialog(manager: this, space: space),
        ),
      ),
      if (gateway.isAdmin) ...[
        ..._moves(context, space.id),
        const PopupMenuDivider(),
        _item(context, 'Delete Space…', () async {
          if (await confirm(
            context,
            title: 'Delete ${space.name}?',
            message:
                'Delete the space ${space.name}? Its channels move to the top level.',
            action: 'Delete',
          )) {
            await _run(() => api.deleteSpace(space.id));
          }
        }, danger: true),
      ],
    ]);
  }

  // --- Order ---------------------------------------------------------------

  /// Spaces and channels outside them share one order; channels in a
  /// space have their own.
  List<String> _siblings(String id) {
    final channel = gateway.channel(id)?.channel;
    if (channel?.space case final space?) {
      return (gateway.channels.where((v) => v.channel.space == space).toList()
            ..sort((a, b) => a.channel.position.compareTo(b.channel.position)))
          .map((v) => v.channel.id)
          .toList();
    }
    return topLevel(gateway).map((e) => e.id).toList();
  }

  List<PopupMenuEntry<VoidCallback>> _moves(BuildContext context, String id) {
    final siblings = _siblings(id);
    final at = siblings.indexOf(id);
    return [
      if (at > 0) _item(context, 'Move Up', () => _move(id, -1)),
      if (at >= 0 && at < siblings.length - 1)
        _item(context, 'Move Down', () => _move(id, 1)),
    ];
  }

  /// The channel list's order as PUT /api/layout takes it, in lists that
  /// can be changed in place.
  List<Map<String, dynamic>> _layout() => [
    for (final entry in topLevel(gateway))
      if (entry.space case final space?)
        {
          'kind': 'space',
          'id': space.id,
          'channels': <String>[
            for (final v
                in gateway.channels
                    .where((v) => v.channel.space == space.id)
                    .toList()
                  ..sort(
                    (a, b) => a.channel.position.compareTo(b.channel.position),
                  ))
              v.channel.id,
          ],
        }
      else
        {'kind': 'channel', 'id': entry.id},
  ];

  Future<void> _save(List<Map<String, dynamic>> items) async {
    try {
      await api.setLayout(items);
    } catch (e) {
      debugPrint('cannot reorder: $e');
      toast('Cannot reorder.');
    }
  }

  Future<void> _move(String id, int by) async {
    final items = _layout();
    void swap(List<dynamic> list, Object? Function(dynamic) idOf) {
      final from = list.indexWhere((e) => idOf(e) == id);
      final to = from + by;
      if (from < 0 || to < 0 || to >= list.length) return;
      list.insert(to, list.removeAt(from));
    }

    swap(items, (e) => (e as Map<String, dynamic>)['id']);
    for (final item in items) {
      if (item['channels'] case final List<String> channels) {
        swap(channels, (e) => e);
      }
    }
    await _save(items);
  }

  // --- Dragging (admins) -------------------------------------------------

  /// What is being dragged right now, for the drop zone at the end.
  final dragging = ValueNotifier<Dragged?>(null);

  /// Puts what was dragged where it was dropped, as the web client does.
  Future<void> drop(Dragged moving, DropTarget target) async {
    if (target case DropBefore(:final id) when id == moving.id) return;
    final items = _layout();
    int spaceWith(String id) => items.indexWhere(
      (i) => i['kind'] == 'space' && (i['channels'] as List).contains(id),
    );
    if (moving.space) {
      final entry = items.removeAt(
        items.indexWhere((i) => i['id'] == moving.id),
      );
      // Spaces live at the top level: a drop inside a space means before it.
      final anchor = switch (target) {
        DropEnd() => null,
        DropInto(:final space) => space,
        DropBefore(:final id) => id,
      };
      var at = anchor == null ? -1 : items.indexWhere((i) => i['id'] == anchor);
      if (anchor != null && at < 0) at = spaceWith(anchor);
      items.insert(at < 0 ? items.length : at, entry);
    } else {
      for (final item in items) {
        (item['channels'] as List<String>?)?.remove(moving.id);
      }
      items.removeWhere((i) => i['kind'] == 'channel' && i['id'] == moving.id);
      final entry = <String, dynamic>{'kind': 'channel', 'id': moving.id};
      switch (target) {
        case DropEnd():
          items.add(entry);
        case DropInto(:final space):
          final holder = items.where((i) => i['id'] == space).firstOrNull;
          (holder?['channels'] as List<String>?)?.add(moving.id);
        case DropBefore(:final id):
          final at = items.indexWhere((i) => i['id'] == id);
          final holder = spaceWith(id);
          if (at >= 0) {
            items.insert(at, entry);
          } else if (holder >= 0) {
            final channels = items[holder]['channels'] as List<String>;
            channels.insert(channels.indexOf(id), moving.id);
          }
      }
    }
    await _save(items);
  }

  // --- Inviting ------------------------------------------------------------

  /// Copies a link to [view]. Restricted channels get a one-time key from
  /// those who may moderate them.
  Future<void> copyInvite(ChannelView view) async {
    final channel = view.channel;
    var url = gateway.session.server.origin
        .replace(path: '/invite/${channel.id}')
        .toString();
    final restricted =
        channel.flags.any || (spaceOf(channel)?.flags.any ?? false);
    final String message;
    if (restricted && view.can('MODERATE')) {
      try {
        url += '?key=${await api.createInvite(channel.id)}';
      } on ApiException {
        toast('Cannot create an invite.');
        return;
      }
      message =
          'Invite to ${channel.name} copied. Once someone uses it, it lets '
          'anyone in for 10 minutes; unused, it lasts a day.';
    } else if (restricted) {
      message =
          'Invite link to ${channel.name} copied. It only works for people '
          'the channel already lets in.';
    } else {
      message = 'Invite link to ${channel.name} copied.';
    }
    await Clipboard.setData(ClipboardData(text: url));
    toast(message);
  }
}

/// A channel or a space being dragged.
typedef Dragged = ({String id, bool space, String name});

/// Where a dragged channel or space lands.
sealed class DropTarget {
  const DropTarget();
}

/// Before a channel, or for a space, before another space.
class DropBefore extends DropTarget {
  const DropBefore(this.id);
  final String id;
}

/// At the end of a space's channels.
class DropInto extends DropTarget {
  const DropInto(this.space);
  final String space;
}

/// At the end of the list.
class DropEnd extends DropTarget {
  const DropEnd();
}

/// One entry of the channel list's top level: a space or a channel outside
/// any space, in their shared order.
typedef TopEntry = ({String id, int position, Space? space, ChannelView? view});

List<TopEntry> topLevel(Gateway gateway) => [
  for (final space in gateway.spaces)
    (id: space.id, position: space.position, space: space, view: null),
  for (final view in gateway.channels.where((v) => v.channel.space == null))
    (
      id: view.channel.id,
      position: view.channel.position,
      space: null,
      view: view,
    ),
]..sort((a, b) => a.position.compareTo(b.position));

class _HeaderEntry extends PopupMenuEntry<VoidCallback> {
  const _HeaderEntry({required this.title, this.detail});

  final String title;
  final String? detail;

  @override
  double get height => detail == null ? 36 : 48;

  @override
  bool represents(VoidCallback? value) => false;

  @override
  State<_HeaderEntry> createState() => _HeaderEntryState();
}

class _HeaderEntryState extends State<_HeaderEntry> {
  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.title,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontWeight: FontWeight.w700, color: palette.text),
          ),
          if (widget.detail case final detail?)
            Text(detail, style: TextStyle(fontSize: 12, color: palette.muted)),
        ],
      ),
    );
  }
}

/// How loud someone is for me, 0 to 200 percent.
class _VolumeEntry extends PopupMenuEntry<VoidCallback> {
  const _VolumeEntry({required this.preferences, required this.person});

  final Preferences preferences;
  final Participant person;

  @override
  double get height => 64;

  @override
  bool represents(VoidCallback? value) => false;

  @override
  State<_VolumeEntry> createState() => _VolumeEntryState();
}

class _VolumeEntryState extends State<_VolumeEntry> {
  String get _key => personKey(widget.person);
  late double _volume = widget.preferences.volumes[_key] ?? 1;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return SizedBox(
      width: 240,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 6, 4, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Volume ${(_volume * 100).round()}%',
              style: TextStyle(fontSize: 13, color: palette.muted),
            ),
            Slider(
              value: _volume,
              max: 2,
              divisions: 40,
              onChanged: (value) {
                setState(() => _volume = value);
                widget.preferences.volumes[_key] = value;
                widget.preferences.changed();
              },
            ),
          ],
        ),
      ),
    );
  }
}

// --- Forms -------------------------------------------------------------------
//
// Each one is a SettingsSheet (settings_sheet.dart): a page on a phone, a
// sheet in the middle of a wide window. Errors from the server show under
// the first group, where the person is looking, not in a toast behind it.

const _bitrates = [32, 48, 64, 96, 128, 192, 256, 320, 510];

String _kbps(int value) => switch (value) {
  64 => '64 kbps (speech)',
  >= 256 => '$value kbps (music)',
  _ => '$value kbps',
};

/// Who may own a channel or a space, for a picker: nobody, or an account.
/// The current owner stays listed while the accounts load.
List<(String?, String)> _owners(List<AccountSummary> accounts, String? owner) =>
    [
      (null, 'Nobody'),
      for (final a in accounts) (a.id, '${a.displayName} (@${a.username})'),
      if (owner != null && !accounts.any((a) => a.id == owner))
        (owner, accounts.isEmpty ? '…' : 'Someone else'),
    ];

/// A new channel, or for admins a new space.
class CreateDialog extends StatefulWidget {
  const CreateDialog({super.key, required this.manager, this.space});

  final Manager manager;

  /// The space a new channel goes into first.
  final String? space;

  @override
  State<CreateDialog> createState() => _CreateDialogState();
}

class _CreateDialogState extends State<CreateDialog> {
  Gateway get _gateway => widget.manager.gateway;
  late final _spaces = [
    for (final s in _gateway.spaces)
      if (_gateway.managesSpace(s)) s,
  ];
  var _space = false;
  late final _name = TextEditingController()
    ..addListener(() => setState(() {}));
  late String? _in =
      widget.space ?? (_gateway.isAdmin ? null : _spaces.firstOrNull?.id);
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final name = _name.text.trim();
    try {
      final api = widget.manager.api;
      if (_space) {
        await api.createSpace(name);
      } else {
        await api.createChannel(name, space: _in);
      }
      if (mounted) Navigator.pop(context);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final named = _name.text.trim().isNotEmpty;
    return SettingsSheet(
      title: _space ? 'New Space' : 'New Channel',
      action: 'Create',
      dirty: named,
      onAction: named ? _create : null,
      children: [
        if (_gateway.isAdmin && widget.space == null)
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: false, label: Text('Channel')),
              ButtonSegment(value: true, label: Text('Space')),
            ],
            selected: {_space},
            showSelectedIcon: false,
            onSelectionChanged: (s) => setState(() => _space = s.first),
          ),
        SettingsGroup(
          footer: _space
              ? 'A folder that groups channels in the sidebar.'
              : 'A voice room people join, with its own chat.',
          error: _error,
          children: [
            TextFieldRow(
              label: 'Name',
              controller: _name,
              hint: _space ? 'DOTA 2' : 'Team Blue',
              maxLength: 64,
              autofocus: true,
            ),
            if (!_space)
              PickerRow<String?>(
                label: 'Space',
                value: _in,
                options: [
                  if (_gateway.isAdmin) (null, 'None'),
                  for (final s in _spaces) (s.id, s.name),
                ],
                onChanged: (id) => setState(() => _in = id),
              ),
          ],
        ),
      ],
    );
  }
}

class ChannelSettingsDialog extends StatefulWidget {
  const ChannelSettingsDialog({
    super.key,
    required this.manager,
    required this.view,
  });

  final Manager manager;
  final ChannelView view;

  @override
  State<ChannelSettingsDialog> createState() => _ChannelSettingsDialogState();
}

class _ChannelSettingsDialogState extends State<ChannelSettingsDialog> {
  Manager get _manager => widget.manager;
  Gateway get _gateway => _manager.gateway;
  Channel get _channel => widget.view.channel;

  late final _name = TextEditingController(text: _channel.name)
    ..addListener(_edited);
  late final _limit = TextEditingController(
    text: _channel.maxParticipants?.toString() ?? '',
  )..addListener(_edited);
  late String? _space = _channel.space;
  late String? _owner = _channel.owner;
  late int _bitrate = _channel.audio.bitrate ~/ 1000;
  late bool _stereo = _channel.audio.stereo;
  late AccessFlags _flags = _channel.flags;
  List<AccountSummary> _accounts = [];
  String? _error;

  void _edited() => setState(() {});

  @override
  void initState() {
    super.initState();
    if (_gateway.isAdmin) {
      _manager.api
          .accounts()
          .then((a) {
            if (mounted) setState(() => _accounts = a);
          })
          .catchError((Object _) {});
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _limit.dispose();
    super.dispose();
  }

  /// Spaces the channel may move to: any for admins; otherwise the one it
  /// is in and those the person owns.
  List<Space> get _spaces => [
    for (final s in _gateway.spaces)
      if (_gateway.isAdmin ||
          s.id == _channel.space ||
          _gateway.managesSpace(s))
        s,
  ];

  /// A name, and a limit from 1 to 99 or none.
  bool get _valid {
    final limit = _limit.text.trim();
    final number = int.tryParse(limit);
    return _name.text.trim().isNotEmpty &&
        (limit.isEmpty || (number != null && number >= 1 && number <= 99));
  }

  /// What the server is told: only what changed.
  Map<String, dynamic> get _changes {
    final name = _name.text.trim();
    final limit = int.tryParse(_limit.text.trim());
    return {
      if (name != _channel.name) 'name': name,
      if (_space != _channel.space) 'space': _space,
      if (_gateway.isAdmin && _owner != _channel.owner) 'owner': _owner,
      if (limit != _channel.maxParticipants) 'max_participants': limit,
      if (_bitrate * 1000 != _channel.audio.bitrate ||
          _stereo != _channel.audio.stereo)
        'audio': {'bitrate': _bitrate * 1000, 'stereo': _stereo},
      if (_flags != _channel.flags) 'flags': _flags.toJson(),
    };
  }

  Future<void> _save() async {
    try {
      await _manager.api.updateChannel(_channel.id, _changes);
      if (mounted) Navigator.pop(context);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    }
  }

  Future<void> _delete() async {
    if (!await confirm(
      context,
      title: 'Delete ${_channel.name}?',
      message: 'Delete ${_channel.name}? Everyone inside is dropped.',
      action: 'Delete',
    )) {
      return;
    }
    try {
      await _manager.api.deleteChannel(_channel.id);
      if (mounted) Navigator.pop(context);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final inherited =
        _gateway.spaces.where((s) => s.id == _space).firstOrNull?.flags ??
        const AccessFlags();
    final bitrates = {..._bitrates, _bitrate}.toList()..sort();
    final changed = _changes.isNotEmpty;
    return SettingsSheet(
      title: 'Channel Settings',
      action: 'Save',
      dirty: changed,
      onAction: changed && _valid ? _save : null,
      children: [
        SettingsGroup(
          footer: _gateway.isAdmin
              ? 'The owner manages this channel. Only admins choose who '
                    'owns it.'
              : null,
          error: _error,
          children: [
            TextFieldRow(label: 'Name', controller: _name, maxLength: 64),
            PickerRow<String?>(
              label: 'Space',
              value: _space,
              options: [
                if (_gateway.isAdmin || _channel.space == null) (null, 'None'),
                for (final s in _spaces) (s.id, s.name),
              ],
              onChanged: (id) => setState(() => _space = id),
            ),
            if (_gateway.isAdmin)
              PickerRow<String?>(
                label: 'Owner',
                value: _owner,
                options: _owners(_accounts, _owner),
                onChanged: (id) => setState(() => _owner = id),
              ),
          ],
        ),
        SettingsGroup(
          header: 'People and Sound',
          footer:
              'When the channel is full, only people who manage it can '
              'still join. From 1 to 99 people, or no limit.',
          children: [
            TextFieldRow(
              label: 'Max People',
              controller: _limit,
              hint: 'No limit',
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(2),
              ],
            ),
            PickerRow<int>(
              label: 'Audio Quality',
              value: _bitrate,
              options: [for (final b in bitrates) (b, _kbps(b))],
              onChanged: (b) => setState(() => _bitrate = b),
            ),
            SwitchRow(
              label: 'Stereo',
              value: _stereo,
              onChanged: (on) => setState(() => _stereo = on),
            ),
          ],
        ),
        SettingsGroup(
          header: 'Access',
          footer: 'Edit the whitelist in the web client for now.',
          children: _accessRows(
            flags: _flags,
            inherited: inherited,
            onChanged: (flags) => setState(() => _flags = flags),
          ),
        ),
        SettingsGroup(
          children: [
            ButtonRow(
              label: 'Delete Channel…',
              destructive: true,
              onTap: _delete,
            ),
          ],
        ),
      ],
    );
  }
}

class SpaceSettingsDialog extends StatefulWidget {
  const SpaceSettingsDialog({
    super.key,
    required this.manager,
    required this.space,
  });

  final Manager manager;
  final Space space;

  @override
  State<SpaceSettingsDialog> createState() => _SpaceSettingsDialogState();
}

class _SpaceSettingsDialogState extends State<SpaceSettingsDialog> {
  Manager get _manager => widget.manager;
  bool get _admin => _manager.gateway.isAdmin;
  Space get _space => widget.space;
  late final _name = TextEditingController(text: _space.name)
    ..addListener(() => setState(() {}));
  late String? _owner = _space.owner;
  late AccessFlags _flags = _space.flags;
  List<AccountSummary> _accounts = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    if (_admin) {
      _manager.api
          .accounts()
          .then((a) {
            if (mounted) setState(() => _accounts = a);
          })
          .catchError((Object _) {});
    }
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Map<String, dynamic> get _changes {
    final name = _name.text.trim();
    return {
      if (name != _space.name) 'name': name,
      if (_admin && _owner != _space.owner) 'owner': _owner,
      if (_flags != _space.flags) 'flags': _flags.toJson(),
    };
  }

  Future<void> _save() async {
    try {
      await _manager.api.updateSpace(_space.id, _changes);
      if (mounted) Navigator.pop(context);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final changed = _changes.isNotEmpty;
    return SettingsSheet(
      title: 'Space Settings',
      action: 'Save',
      dirty: changed,
      onAction: changed && _name.text.trim().isNotEmpty ? _save : null,
      children: [
        SettingsGroup(
          footer: _admin
              ? 'The owner manages the space and every channel in it. Only '
                    'admins choose who owns it.'
              : null,
          error: _error,
          children: [
            TextFieldRow(label: 'Name', controller: _name, maxLength: 64),
            if (_admin)
              PickerRow<String?>(
                label: 'Owner',
                value: _owner,
                options: _owners(_accounts, _owner),
                onChanged: (id) => setState(() => _owner = id),
              ),
          ],
        ),
        SettingsGroup(
          header: 'Access',
          footer:
              'These limits apply to every channel in the space; a channel '
              'can only add its own. Edit the whitelist in the web client '
              'for now.',
          children: _accessRows(
            flags: _flags,
            inherited: const AccessFlags(),
            onChanged: (flags) => setState(() => _flags = flags),
          ),
        ),
      ],
    );
  }
}

/// Accounts Only, Whitelist Only and Hidden; those its space already sets
/// show on and can't be turned off here.
List<Widget> _accessRows({
  required AccessFlags flags,
  required AccessFlags inherited,
  required ValueChanged<AccessFlags> onChanged,
}) {
  Widget row(
    String label,
    String detail,
    bool on,
    bool fromSpace,
    AccessFlags Function(bool) set,
  ) => SwitchRow(
    label: label,
    detail: fromSpace ? 'Set by the space' : detail,
    value: on || fromSpace,
    onChanged: fromSpace ? null : (value) => onChanged(set(value)),
  );
  return [
    row(
      'Accounts Only',
      'No guests',
      flags.authRequired,
      inherited.authRequired,
      (v) => flags.copyWith(authRequired: v),
    ),
    row(
      'Whitelist Only',
      'Only the people and roles on its list',
      flags.whitelist,
      inherited.whitelist,
      (v) => flags.copyWith(whitelist: v),
    ),
    row(
      'Hidden',
      'Invisible to those who may not enter',
      flags.hidden,
      inherited.hidden,
      (v) => flags.copyWith(hidden: v),
    ),
  ];
}

/// Summon someone into the call: a search among those who could come.
class SummonDialog extends StatefulWidget {
  const SummonDialog({super.key, required this.manager, required this.view});

  final Manager manager;
  final ChannelView view;

  @override
  State<SummonDialog> createState() => _SummonDialogState();
}

class _SummonDialogState extends State<SummonDialog> {
  late final _query = TextEditingController()..addListener(_typed);
  String _searched = '';
  Timer? _debounce;
  int _ticket = 0;
  List<AccountSummary> _found = [];
  AccountSummary? _chosen;
  String? _note;
  String? _error;

  @override
  void dispose() {
    _debounce?.cancel();
    _query.dispose();
    super.dispose();
  }

  /// The controller also speaks up when only the cursor moves.
  void _typed() {
    final query = _query.text.trim();
    if (query == _searched) return;
    _searched = query;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 150), () => _search(query));
  }

  Future<void> _search(String query) async {
    final ticket = ++_ticket;
    if (query.isEmpty) {
      setState(() {
        _found = [];
        _chosen = null;
        _note = null;
        _error = null;
      });
      return;
    }
    try {
      final found = await widget.manager.api.summonable(
        widget.view.channel.id,
        query,
      );
      if (!mounted || ticket != _ticket) return;
      final bare = query.replaceFirst('@', '').toLowerCase();
      setState(() {
        _found = found;
        _chosen =
            found.where((a) => a.username.toLowerCase() == bare).firstOrNull ??
            found.firstOrNull;
        _note = found.isEmpty ? 'Nobody matching who could come here.' : null;
        _error = null;
      });
    } on ApiException {
      if (mounted && ticket == _ticket) {
        setState(() => _error = 'Cannot search.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final gateway = widget.manager.gateway;
    final chosen = _chosen;
    return SettingsSheet(
      title: 'Summon to ${widget.view.channel.name}',
      action: 'Summon',
      onAction: chosen == null
          ? null
          : () async => Navigator.pop(context, chosen),
      children: [
        SettingsGroup(
          footer:
              _note ??
              'They get a notification that you are waiting. Once per '
                  '5 minutes per person.',
          error: _error,
          children: [
            TextFieldRow(
              label: 'Nickname',
              controller: _query,
              hint: 'Who?',
              autofocus: true,
              autocorrect: false,
            ),
          ],
        ),
        if (_found.isNotEmpty)
          SettingsGroup(
            children: [
              for (final account in _found)
                CheckRow(
                  leading: Avatar(
                    name: account.displayName,
                    size: 32,
                    image: gateway.avatar(account.id, account.avatar),
                  ),
                  label: account.displayName,
                  detail: '@${account.username}',
                  selected: account.id == chosen?.id,
                  onTap: () => setState(() => _chosen = account),
                ),
            ],
          ),
      ],
    );
  }
}
