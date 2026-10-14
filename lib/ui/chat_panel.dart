// One channel's chat: history, live messages, a composer. It disappears
// 4 hours after the last message. The same layout as the web client's
// ChatPanel.

import 'dart:async';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/chat.dart';
import '../data/gateway.dart';
import '../data/protocol.dart';
import '../src/rust/api/picture.dart';
import '../theme.dart';
import 'common.dart';

const _maxChars = 2000;

class ChatPanel extends StatefulWidget {
  const ChatPanel({
    super.key,
    required this.chats,
    required this.gateway,
    required this.view,
    required this.onClose,
  });

  final Chats chats;
  final Gateway gateway;
  final ChannelView view;
  final VoidCallback onClose;

  @override
  State<ChatPanel> createState() => _ChatPanelState();
}

class _ChatPanelState extends State<ChatPanel> {
  final _draft = TextEditingController();
  late final _input = FocusNode(onKeyEvent: _key);
  Picture? _picture;
  bool _preparing = false;

  /// Moves "clears in" along while the chat is on screen.
  Timer? _clock;

  Chats get _chats => widget.chats;
  String get _channel => widget.view.channel.id;

  @override
  void initState() {
    super.initState();
    _clock = Timer.periodic(
      const Duration(seconds: 30),
      (_) => setState(() {}),
    );
  }

  @override
  void dispose() {
    _clock?.cancel();
    _draft.dispose();
    _input.dispose();
    super.dispose();
  }

  /// Enter sends, Shift+Enter starts a new line.
  KeyEventResult _key(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.enter &&
        !HardwareKeyboard.instance.isShiftPressed) {
      _send();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void _send() {
    final body = _draft.text.trim();
    final picture = _picture;
    if (body.isEmpty && picture == null) return;
    _chats.send(_channel, body, picture: picture);
    _draft.clear();
    setState(() => _picture = null);
  }

  Future<void> _attach() async {
    final file = await openFile(
      acceptedTypeGroups: const [
        XTypeGroup(
          label: 'Pictures',
          extensions: ['jpg', 'jpeg', 'png', 'gif', 'webp'],
          mimeTypes: ['image/jpeg', 'image/png', 'image/gif', 'image/webp'],
        ),
      ],
    );
    if (file == null) return;
    setState(() => _preparing = true);
    try {
      final prepared = await preparePicture(bytes: await file.readAsBytes());
      if (mounted) setState(() => _picture = prepared);
      _input.requestFocus();
    } catch (e) {
      _chats.report(
        e.toString().contains('too large')
            ? 'This picture is too large.'
            : "This picture can't be read.",
      );
    } finally {
      if (mounted) setState(() => _preparing = false);
    }
  }

  String _clearsIn(DateTime? at) {
    if (at == null) return 'Messages vanish 4 h after the last one';
    final minutes = at.difference(DateTime.now()).inMinutes.clamp(1, 1 << 20);
    final hours = minutes ~/ 60;
    final left = hours > 0 ? '$hours h ${minutes % 60} min' : '$minutes min';
    return 'Clears in $left unless someone writes';
  }

  /// A message continues the previous one: same author within 5 minutes.
  static bool _continues(List<ChatMessage> messages, int i) {
    if (i == 0) return false;
    final (a, b) = (messages[i - 1], messages[i]);
    return a.authorName == b.authorName &&
        a.author == b.author &&
        b.sentAt.difference(a.sentAt) < const Duration(minutes: 5);
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final room = _chats.room(_channel);
    final messages = room.messages;
    final moderator = widget.view.can('MODERATE');
    final me = _chats.account;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Chat',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: palette.text,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.lock_outline,
                          size: 11,
                          color: palette.muted,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            _clearsIn(room.expiresAt),
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: palette.muted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Close Chat',
                icon: Icon(Icons.close, color: palette.muted, size: 20),
                onPressed: widget.onClose,
              ),
            ],
          ),
        ),
        Divider(height: 1, color: palette.separator),
        Expanded(
          child: messages.isEmpty
              ? Center(
                  child: Text(
                    room.loaded ? 'No messages yet. Say hi!' : 'Loading…',
                    style: TextStyle(color: palette.muted),
                  ),
                )
              // Reversed: it starts at the newest message and stays there.
              : ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final i = messages.length - 1 - index;
                    final m = messages[i];
                    return _MessageTile(
                      key: ValueKey(m.id),
                      chats: _chats,
                      message: m,
                      continues: _continues(messages, i),
                      avatar: widget.gateway.avatar(m.author, m.avatar),
                      canDelete: moderator || (me != null && m.author == me),
                    );
                  },
                ),
        ),
        if (_chats.waiting.contains(_channel))
          _Status('Getting the chat key…')
        else if ((_chats.uploading[_channel] ?? 0) > 0)
          _Status('Sending the picture…'),
        if (_picture != null || _preparing)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
            child: _picture == null
                ? Text(
                    'Preparing the picture…',
                    style: TextStyle(color: palette.muted, fontSize: 13),
                  )
                : Align(
                    alignment: Alignment.centerLeft,
                    child: _Attachment(
                      picture: _picture!,
                      onRemove: () => setState(() => _picture = null),
                    ),
                  ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                tooltip: 'Add Picture',
                icon: Icon(
                  Icons.add_photo_alternate_outlined,
                  color: palette.muted,
                ),
                onPressed: _preparing ? null : _attach,
              ),
              Expanded(
                child: TextField(
                  controller: _draft,
                  focusNode: _input,
                  minLines: 1,
                  maxLines: 6,
                  maxLength: _maxChars,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    hintText: 'Message ${widget.view.channel.name}',
                    counterText: '',
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              IconButton.filled(
                tooltip: 'Send',
                icon: const Icon(Icons.arrow_upward, size: 20),
                onPressed: _send,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Status extends StatelessWidget {
  const _Status(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
    child: Text(
      text,
      style: TextStyle(color: context.palette.muted, fontSize: 13),
    ),
  );
}

class _Attachment extends StatelessWidget {
  const _Attachment({required this.picture, required this.onRemove});

  final Picture picture;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final pixels = (72 * MediaQuery.devicePixelRatioOf(context)).round();
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.memory(
            picture.bytes,
            height: 72,
            cacheHeight: pixels,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          right: -6,
          top: -6,
          child: Material(
            color: context.palette.text,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onRemove,
              child: Padding(
                padding: const EdgeInsets.all(3),
                child: Icon(Icons.close, size: 12, color: context.palette.bg),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MessageTile extends StatefulWidget {
  const _MessageTile({
    super.key,
    required this.chats,
    required this.message,
    required this.continues,
    required this.avatar,
    required this.canDelete,
  });

  final Chats chats;
  final ChatMessage message;
  final bool continues;
  final Uri? avatar;
  final bool canDelete;

  @override
  State<_MessageTile> createState() => _MessageTileState();
}

class _MessageTileState extends State<_MessageTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final m = widget.message;
    final body = <Widget>[
      if (m.text == null)
        Text(
          "Encrypted with a key this device doesn't have: sent before it "
          'joined the chat.',
          style: TextStyle(
            color: palette.tertiary,
            fontStyle: FontStyle.italic,
            fontSize: 13,
          ),
        )
      else if (m.text!.isNotEmpty)
        _MessageText(m.text!),
      if (m.image != null && m.text != null)
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: _ChatPicture(chats: widget.chats, message: m),
        ),
    ];

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Container(
        color: _hovered ? palette.fill.withValues(alpha: 0.5) : null,
        padding: EdgeInsets.fromLTRB(12, widget.continues ? 1 : 8, 8, 1),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 32,
              child: widget.continues
                  ? null
                  : Avatar(name: m.authorName, size: 32, image: widget.avatar),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!widget.continues)
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            m.authorName,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: palette.text,
                            ),
                          ),
                        ),
                        if (m.author == null) ...[
                          const SizedBox(width: 6),
                          Text(
                            'guest',
                            style: TextStyle(
                              fontSize: 12,
                              color: palette.muted,
                            ),
                          ),
                        ],
                        const SizedBox(width: 6),
                        Text(
                          TimeOfDay.fromDateTime(m.sentAt).format(context),
                          style: TextStyle(fontSize: 12, color: palette.muted),
                        ),
                      ],
                    ),
                  ...body,
                ],
              ),
            ),
            SizedBox(
              width: 28,
              child: widget.canDelete && _hovered
                  ? IconButton(
                      tooltip: 'Delete',
                      padding: EdgeInsets.zero,
                      iconSize: 16,
                      constraints: const BoxConstraints.tightFor(
                        width: 28,
                        height: 28,
                      ),
                      icon: Icon(Icons.delete_outline, color: palette.muted),
                      onPressed: () => widget.chats.remove(m.channel, m.id),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

/// Plain text with links made clickable, and selectable.
class _MessageText extends StatefulWidget {
  const _MessageText(this.text);

  final String text;

  @override
  State<_MessageText> createState() => _MessageTextState();
}

class _MessageTextState extends State<_MessageText> {
  static final _link = RegExp(r'https?://[^\s<>"]+');
  final List<TapGestureRecognizer> _taps = [];

  @override
  void dispose() {
    for (final tap in _taps) {
      tap.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    for (final tap in _taps) {
      tap.dispose();
    }
    _taps.clear();
    final spans = <TextSpan>[];
    var at = 0;
    for (final match in _link.allMatches(widget.text)) {
      if (match.start > at) {
        spans.add(TextSpan(text: widget.text.substring(at, match.start)));
      }
      final url = match.group(0)!;
      final tap = TapGestureRecognizer()
        ..onTap = () =>
            launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      _taps.add(tap);
      spans.add(
        TextSpan(
          text: url,
          recognizer: tap,
          mouseCursor: SystemMouseCursors.click,
          style: TextStyle(
            color: palette.accent,
            decoration: TextDecoration.underline,
          ),
        ),
      );
      at = match.end;
    }
    if (at < widget.text.length) {
      spans.add(TextSpan(text: widget.text.substring(at)));
    }
    return SelectableText.rich(
      TextSpan(
        style: TextStyle(color: palette.text, height: 1.35),
        children: spans,
      ),
    );
  }
}

/// A message's picture, fetched and decrypted when it comes into view; a
/// click shows it whole.
class _ChatPicture extends StatefulWidget {
  const _ChatPicture({required this.chats, required this.message});

  final Chats chats;
  final ChatMessage message;

  @override
  State<_ChatPicture> createState() => _ChatPictureState();
}

class _ChatPictureState extends State<_ChatPicture> {
  @override
  void initState() {
    super.initState();
    unawaited(widget.chats.picture(widget.message));
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final image = widget.message.image!;
    const box = 280.0;
    final scale = [
      1.0,
      box / image.width,
      box / image.height,
    ].reduce((a, b) => a < b ? a : b);
    final size = Size(
      (image.width * scale).clamp(48, box),
      (image.height * scale).clamp(48, box),
    );
    final id = image.id;
    final loaded = widget.chats.pictures.containsKey(id);
    final bytes = widget.chats.pictures[id];
    final Widget child;
    if (!loaded) {
      child = ColoredBox(
        color: palette.fill,
        child: Icon(Icons.image_outlined, color: palette.tertiary),
      );
    } else if (bytes == null) {
      child = ColoredBox(
        color: palette.fill,
        child: Center(
          child: Text(
            "The picture didn't load.",
            textAlign: TextAlign.center,
            style: TextStyle(color: palette.muted, fontSize: 12),
          ),
        ),
      );
    } else {
      final ratio = MediaQuery.devicePixelRatioOf(context);
      child = MouseRegion(
        cursor: SystemMouseCursors.zoomIn,
        child: GestureDetector(
          onTap: () => _view(context, bytes),
          child: Image.memory(
            bytes,
            fit: BoxFit.cover,
            // Decoded at the size it shows.
            cacheWidth: (size.width * ratio).round(),
            gaplessPlayback: true,
          ),
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox.fromSize(size: size, child: child),
    );
  }

  void _view(BuildContext context, Uint8List bytes) => showDialog<void>(
    context: context,
    barrierColor: Colors.black87,
    builder: (context) => GestureDetector(
      onTap: () => Navigator.pop(context),
      child: InteractiveViewer(
        maxScale: 6,
        child: Center(child: Image.memory(bytes)),
      ),
    ),
  );
}
