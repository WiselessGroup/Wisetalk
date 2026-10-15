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
          () => showDialog<void>(
            context: context,
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
        () => showDialog<void>(
          context: context,
          builder: (_) => CreateDialog(manager: this, space: space.id),
        ),
      ),
      _item(
        context,
        'Space Settings…',
        () => showDialog<void>(
          context: context,
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

// --- Dialogs -----------------------------------------------------------------

const _bitrates = [32, 48, 64, 96, 128, 192, 256, 320, 510];

String _kbps(int value) => switch (value) {
  64 => '64 kbps (speech)',
  >= 256 => '$value kbps (music)',
  _ => '$value kbps',
};

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
  final _name = TextEditingController();
  late String? _in =
      widget.space ?? (_gateway.isAdmin ? null : _spaces.firstOrNull?.id);
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final name = _name.text.trim();
    if (name.isEmpty) return;
    setState(() => _busy = true);
    try {
      final api = widget.manager.api;
      if (_space) {
        await api.createSpace(name);
      } else {
        await api.createChannel(name, space: _in);
      }
      if (mounted) Navigator.pop(context);
    } on ApiException catch (e) {
      widget.manager.toast(e.message);
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return AlertDialog(
      title: Text(_space ? 'New Space' : 'New Channel'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_gateway.isAdmin && widget.space == null) ...[
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: false, label: Text('Channel')),
                  ButtonSegment(value: true, label: Text('Space')),
                ],
                selected: {_space},
                onSelectionChanged: (s) => setState(() => _space = s.first),
              ),
              const SizedBox(height: 12),
            ],
            Text(
              _space
                  ? 'A folder that groups channels in the sidebar.'
                  : 'A voice room people join, with its own chat.',
              style: TextStyle(color: palette.muted, fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _name,
              autofocus: true,
              maxLength: 64,
              decoration: InputDecoration(
                labelText: 'Name',
                hintText: _space ? 'DOTA 2' : 'Team Blue',
              ),
              onSubmitted: (_) => _create(),
            ),
            if (!_space)
              DropdownButtonFormField<String?>(
                initialValue: _in,
                decoration: const InputDecoration(labelText: 'Space'),
                items: [
                  if (_gateway.isAdmin)
                    const DropdownMenuItem(value: null, child: Text('None')),
                  for (final s in _spaces)
                    DropdownMenuItem(value: s.id, child: Text(s.name)),
                ],
                onChanged: (id) => setState(() => _in = id),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _busy ? null : _create,
          child: const Text('Create'),
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

  late final _name = TextEditingController(text: _channel.name);
  late final _limit = TextEditingController(
    text: _channel.maxParticipants?.toString() ?? '',
  );
  late String? _space = _channel.space;
  late String? _owner = _channel.owner;
  late int _bitrate = _channel.audio.bitrate ~/ 1000;
  late bool _stereo = _channel.audio.stereo;
  late AccessFlags _flags = _channel.flags;
  List<AccountSummary> _accounts = [];
  bool _busy = false;

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

  Future<void> _save() async {
    final name = _name.text.trim();
    final limitText = _limit.text.trim();
    final limit = limitText.isEmpty ? null : int.tryParse(limitText);
    if (name.isEmpty ||
        (limitText.isNotEmpty && (limit == null || limit < 1 || limit > 99))) {
      _manager.toast('Give it a name, and a limit from 1 to 99 or none.');
      return;
    }
    final fields = <String, dynamic>{
      if (name != _channel.name) 'name': name,
      if (_space != _channel.space) 'space': _space,
      if (_gateway.isAdmin && _owner != _channel.owner) 'owner': _owner,
      if (limit != _channel.maxParticipants) 'max_participants': limit,
      if (_bitrate * 1000 != _channel.audio.bitrate ||
          _stereo != _channel.audio.stereo)
        'audio': {'bitrate': _bitrate * 1000, 'stereo': _stereo},
      'flags': _flags.toJson(),
    };
    setState(() => _busy = true);
    try {
      await _manager.api.updateChannel(_channel.id, fields);
      if (mounted) Navigator.pop(context);
    } on ApiException catch (e) {
      _manager.toast(e.message);
      if (mounted) setState(() => _busy = false);
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
      _manager.toast(e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final inherited =
        _gateway.spaces.where((s) => s.id == _space).firstOrNull?.flags ??
        const AccessFlags();
    final bitrates = {..._bitrates, _bitrate}.toList()..sort();
    return AlertDialog(
      title: const Text('Channel Settings'),
      scrollable: true,
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            TextField(
              controller: _name,
              maxLength: 64,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            DropdownButtonFormField<String?>(
              initialValue: _space,
              decoration: const InputDecoration(labelText: 'Space'),
              items: [
                if (_gateway.isAdmin || _channel.space == null)
                  const DropdownMenuItem(value: null, child: Text('None')),
                for (final s in _spaces)
                  DropdownMenuItem(value: s.id, child: Text(s.name)),
              ],
              onChanged: (id) => setState(() => _space = id),
            ),
            if (_gateway.isAdmin) ...[
              DropdownButtonFormField<String?>(
                initialValue: _accounts.any((a) => a.id == _owner)
                    ? _owner
                    : null,
                decoration: const InputDecoration(
                  labelText: 'Owner',
                  helperText: 'The owner manages this channel. Only admins choose who owns it.',
                  helperMaxLines: 2,
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Nobody')),
                  for (final a in _accounts)
                    DropdownMenuItem(
                      value: a.id,
                      child: Text(
                        '${a.displayName} (@${a.username})',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                onChanged: (id) => setState(() => _owner = id),
              ),
            ],
            const SizedBox(height: 16),
            _Section('People and Sound'),
            TextField(
              controller: _limit,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Max People',
                hintText: 'No limit',
                helperText: 'When the channel is full, only people who manage it can still join.',
                helperMaxLines: 2,
              ),
            ),
            DropdownButtonFormField<int>(
              initialValue: _bitrate,
              decoration: const InputDecoration(labelText: 'Audio Quality'),
              items: [
                for (final b in bitrates)
                  DropdownMenuItem(value: b, child: Text(_kbps(b))),
              ],
              onChanged: (b) => setState(() => _bitrate = b ?? _bitrate),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Stereo'),
              value: _stereo,
              onChanged: (on) => setState(() => _stereo = on),
            ),
            const SizedBox(height: 8),
            _Section('Access'),
            _AccessSwitches(
              flags: _flags,
              inherited: inherited,
              subject: 'channel',
              onChanged: (flags) => setState(() => _flags = flags),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: _delete,
                style: TextButton.styleFrom(foregroundColor: palette.error),
                child: const Text('Delete Channel…'),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _busy ? null : _save,
          child: const Text('Save'),
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
  Space get _space => widget.space;
  late final _name = TextEditingController(text: _space.name);
  late String? _owner = _space.owner;
  late AccessFlags _flags = _space.flags;
  List<AccountSummary> _accounts = [];
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    if (_manager.gateway.isAdmin) {
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

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty) return;
    setState(() => _busy = true);
    try {
      await _manager.api.updateSpace(_space.id, {
        if (name != _space.name) 'name': name,
        if (_manager.gateway.isAdmin && _owner != _space.owner) 'owner': _owner,
        'flags': _flags.toJson(),
      });
      if (mounted) Navigator.pop(context);
    } on ApiException catch (e) {
      _manager.toast(e.message);
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return AlertDialog(
      title: const Text('Space Settings'),
      scrollable: true,
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            TextField(
              controller: _name,
              maxLength: 64,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            if (_manager.gateway.isAdmin)
              DropdownButtonFormField<String?>(
                initialValue: _accounts.any((a) => a.id == _owner)
                    ? _owner
                    : null,
                decoration: const InputDecoration(
                  labelText: 'Owner',
                  helperText:
                      'The owner manages the space and every channel in it. '
                      'Only admins choose who owns it.',
                  helperMaxLines: 2,
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Nobody')),
                  for (final a in _accounts)
                    DropdownMenuItem(
                      value: a.id,
                      child: Text(
                        '${a.displayName} (@${a.username})',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                onChanged: (id) => setState(() => _owner = id),
              ),
            const SizedBox(height: 16),
            _Section('Access'),
            _AccessSwitches(
              flags: _flags,
              inherited: const AccessFlags(),
              subject: 'space',
              onChanged: (flags) => setState(() => _flags = flags),
            ),
            Text(
              'These limits apply to every channel in the space; a channel '
              'can only add its own.',
              style: TextStyle(color: palette.muted, fontSize: 13),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _busy ? null : _save,
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: context.palette.muted,
    ),
  );
}

/// Accounts Only, Whitelist Only and Hidden; those its space already sets
/// show on and can't be turned off here.
class _AccessSwitches extends StatelessWidget {
  const _AccessSwitches({
    required this.flags,
    required this.inherited,
    required this.subject,
    required this.onChanged,
  });

  final AccessFlags flags;
  final AccessFlags inherited;
  final String subject;
  final ValueChanged<AccessFlags> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget row(
      String label,
      String detail,
      bool on,
      bool fromSpace,
      AccessFlags Function(bool) set,
    ) => SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      subtitle: Text(fromSpace ? 'Set by the space' : detail),
      value: on || fromSpace,
      onChanged: fromSpace ? null : (value) => onChanged(set(value)),
    );
    return Column(
      children: [
        row(
          'Accounts Only',
          'No guests',
          flags.authRequired,
          inherited.authRequired,
          (v) => flags.copyWith(authRequired: v),
        ),
        row(
          'Whitelist Only',
          'Only the people and roles on its list; edit the list in the web client for now',
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
      ],
    );
  }
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
  final _query = TextEditingController();
  Timer? _debounce;
  int _ticket = 0;
  List<AccountSummary> _found = [];
  AccountSummary? _chosen;
  String? _note;

  @override
  void dispose() {
    _debounce?.cancel();
    _query.dispose();
    super.dispose();
  }

  void _search(String text) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 150), () async {
      final ticket = ++_ticket;
      final query = text.trim();
      if (query.isEmpty) {
        setState(() {
          _found = [];
          _chosen = null;
          _note = null;
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
              found
                  .where((a) => a.username.toLowerCase() == bare)
                  .firstOrNull ??
              found.firstOrNull;
          _note = found.isEmpty ? 'Nobody matching who could come here.' : null;
        });
      } on ApiException {
        if (mounted && ticket == _ticket) {
          setState(() => _note = 'Cannot search.');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final gateway = widget.manager.gateway;
    final chosen = _chosen;
    return AlertDialog(
      title: Text('Summon to ${widget.view.channel.name}'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _query,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Nickname'),
              onChanged: _search,
              onSubmitted: (_) {
                if (chosen != null) Navigator.pop(context, chosen);
              },
            ),
            const SizedBox(height: 8),
            for (final account in _found)
              ListTile(
                contentPadding: EdgeInsets.zero,
                selected: account.id == chosen?.id,
                leading: Avatar(
                  name: account.displayName,
                  size: 32,
                  image: gateway.avatar(account.id, account.avatar),
                ),
                title: Text(account.displayName),
                subtitle: Text('@${account.username}'),
                onTap: () => setState(() => _chosen = account),
              ),
            Text(
              _note ??
                  'They get a notification that you are waiting. Once per '
                      '5 minutes per person.',
              style: TextStyle(color: palette.muted, fontSize: 13),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: chosen == null
              ? null
              : () => Navigator.pop(context, chosen),
          child: Text(
            chosen == null ? 'Summon' : 'Summon ${chosen.displayName}',
          ),
        ),
      ],
    );
  }
}
