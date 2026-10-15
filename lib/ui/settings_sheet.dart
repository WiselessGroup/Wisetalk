// The one way the app asks for a form: settings, creating, summoning,
// sharing a screen, adding a server (ADR-0029). Like the web client's
// Dialog.svelte, it picks its look by the window's width. Wide windows get
// a sheet in the middle with the buttons bottom right. Phones get a page
// over the whole screen that rises from the bottom, with Cancel at the top
// left and Save at the top right, as Apple's HIG has it for long forms; a
// swipe down closes it. Short choices rise from the bottom only as far as
// they need.
//
// The body is an inset grouped list, as in iOS Settings and the web
// client's .group/.row classes: SettingsGroup holds rows (TextFieldRow,
// PickerRow, SwitchRow, CheckRow, ButtonRow, or SettingsRow for anything
// else), with a caption under the group for hints.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme.dart';
import 'common.dart';

/// Windows wider than this get a sheet in the middle; narrower ones, a
/// page. 40rem, the web client's breakpoint.
const sheetBreakpoint = 640.0;

/// How a sheet is shown, picked by [showSettingsSheet] when it opens.
enum SheetStyle {
  /// In the middle of a wide window, buttons bottom right.
  dialog,

  /// Over the whole screen, buttons in a bar at the top.
  page,

  /// Rising from the bottom edge as far as its content needs, buttons in a
  /// bar at its top. For short choices without typing.
  bottom,
}

/// Shows the sheet [builder] makes, styled for the window's width. On a
/// phone a [short] sheet rises from the bottom instead of taking the whole
/// screen; the system lets it go on a swipe down without asking, so short
/// sheets have nothing to lose.
Future<T?> showSettingsSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  bool short = false,
}) {
  Widget styled(SheetStyle style) => _Style(
    style: style,
    child: Builder(builder: builder),
  );
  if (MediaQuery.sizeOf(context).width > sheetBreakpoint) {
    return showDialog<T>(
      context: context,
      builder: (_) => styled(SheetStyle.dialog),
    );
  }
  if (short) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: context.palette.sidebar,
      builder: (_) => styled(SheetStyle.bottom),
    );
  }
  return Navigator.of(context)
      .push(_PageSheetRoute<T>(builder: (_) => styled(SheetStyle.page)));
}

/// Which [SheetStyle] the sheets below were opened in.
class _Style extends InheritedWidget {
  const _Style({required this.style, required super.child});

  final SheetStyle style;

  static SheetStyle of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_Style>()?.style ??
      SheetStyle.dialog;

  @override
  bool updateShouldNotify(_Style oldWidget) => style != oldWidget.style;
}

/// A full-screen modal page that slides up from the bottom and back down,
/// as iOS shows one, on every platform.
class _PageSheetRoute<T> extends PageRoute<T> {
  _PageSheetRoute({required this.builder}) : super(fullscreenDialog: true);

  final WidgetBuilder builder;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 350);

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) => builder(context);

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) => SlideTransition(
    position: Tween(begin: const Offset(0, 1), end: Offset.zero).animate(
      CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      ),
    ),
    child: child,
  );
}

/// A form over the app: a title, groups of rows, and its buttons, laid out
/// by how [showSettingsSheet] opened it.
class SettingsSheet extends StatefulWidget {
  const SettingsSheet({
    super.key,
    required this.title,
    required this.children,
    this.action,
    this.onAction,
    this.dirty = false,
    this.wide = false,
  });

  final String title;

  /// [SettingsGroup]s, mostly; anything else that fits the list goes too.
  final List<Widget> children;

  /// What the prominent button says, like Save, Create or Share. Without
  /// one the sheet has Done only: what it changes applies at once.
  final String? action;

  /// Runs on [action] and closes the sheet once it worked. Null while
  /// there's nothing to save or what's filled in won't do: the button
  /// greys out. The button also greys out while it runs.
  final Future<void> Function()? onAction;

  /// Something changed that closing would throw away: Cancel, Back, a
  /// swipe down or a click outside ask first.
  final bool dirty;

  /// Room for pictures in a wide window, like the screens to share.
  final bool wide;

  /// Does what the prominent button does, if it may now. Text fields in
  /// the sheet call it on Enter, as a form on the web submits.
  static void submit(BuildContext context) =>
      context.findAncestorStateOfType<_SettingsSheetState>()?._act();

  @override
  State<SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends State<SettingsSheet> {
  bool _busy = false;
  bool _asking = false;

  /// How far a swipe has pulled the page down, and whether it still is.
  double _drag = 0;
  bool _dragging = false;

  VoidCallback? get _primary {
    if (widget.action == null) return _close;
    if (widget.onAction == null || _busy) return null;
    return _act;
  }

  Future<void> _act() async {
    final action = widget.onAction;
    if (action == null || _busy) return;
    setState(() => _busy = true);
    try {
      await action();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Every way out but the prominent button goes through here, and through
  /// the PopScope in [build] when something changed.
  void _close() => Navigator.maybePop(context);

  Future<void> _closing(bool closed, Object? result) async {
    if (closed || _asking) return;
    _asking = true;
    final discard = await confirm(
      context,
      title: 'Discard Changes?',
      message: 'What you changed here is not saved yet.',
      action: 'Discard',
      cancel: 'Keep Editing',
    );
    _asking = false;
    if (discard && mounted) Navigator.pop(context);
  }

  void _dragBy(double dy) => setState(() {
    _dragging = true;
    _drag = math.max(0, _drag + dy);
  });

  /// Far or fast enough closes the page; it slides on down from where the
  /// finger left it. Otherwise, or when Discard Changes? asks, it settles
  /// back.
  void _dragEnd(double velocity) {
    final away = _drag > 120 || (_drag > 0 && velocity > 700);
    setState(() {
      _dragging = false;
      if (!away || widget.dirty) _drag = 0;
    });
    if (away) _close();
  }

  /// Pulling the list down past its top pulls the page down.
  bool _scrolled(ScrollNotification event) {
    if (event.depth != 0) return false;
    if (event is OverscrollNotification &&
        event.dragDetails != null &&
        event.overscroll < 0) {
      _dragBy(-event.overscroll);
    } else if (event is ScrollUpdateNotification &&
        event.dragDetails != null &&
        _drag > 0) {
      _dragBy(-(event.scrollDelta ?? 0));
    } else if (event is ScrollEndNotification && _dragging) {
      _dragEnd(event.dragDetails?.velocity.pixelsPerSecond.dy ?? 0);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !widget.dirty,
    onPopInvokedWithResult: _closing,
    child: switch (_Style.of(context)) {
      SheetStyle.dialog => _dialog(context),
      SheetStyle.page => _page(context),
      SheetStyle.bottom => _bottom(context),
    },
  );

  Widget _list({
    required EdgeInsets padding,
    bool shrinkWrap = false,
    ScrollPhysics? physics,
  }) => ListView(
    padding: padding,
    shrinkWrap: shrinkWrap,
    physics: physics,
    children: [
      for (final (i, child) in widget.children.indexed) ...[
        if (i > 0) const SizedBox(height: 24),
        child,
      ],
    ],
  );

  Widget _dialog(BuildContext context) {
    final palette = context.palette;
    return Dialog(
      backgroundColor: palette.sidebar,
      insetPadding: const EdgeInsets.all(24),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: widget.wide ? 608 : 512,
          maxHeight: 736,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
              child: _Title(widget.title, size: 20),
            ),
            Flexible(
              child: _list(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                shrinkWrap: true,
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: palette.separator)),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                child: Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (widget.action != null)
                      TextButton(
                        onPressed: _close,
                        child: const Text('Cancel'),
                      ),
                    FilledButton(
                      onPressed: _primary,
                      child: Text(widget.action ?? 'Done'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _page(BuildContext context) {
    final palette = context.palette;
    final insets = MediaQuery.paddingOf(context);
    return ColoredBox(
      color: palette.window,
      child: AnimatedContainer(
        duration: _dragging ? Duration.zero : const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, _drag, 0),
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(_drag > 0 ? 22 : 0),
          ),
          child: Scaffold(
            backgroundColor: palette.sidebar,
            // The keyboard shrinks the list, not the bar: Save stays put
            // and the field being typed in scrolls into view.
            resizeToAvoidBottomInset: true,
            appBar: _bar(context, top: insets.top, draggable: true),
            body: ScrollConfiguration(
              // The page itself moves on a pull past the top; no glow too.
              behavior: ScrollConfiguration.of(context)
                  .copyWith(overscroll: false),
              child: NotificationListener<ScrollNotification>(
                onNotification: _scrolled,
                child: _list(
                  padding: EdgeInsets.fromLTRB(16, 20, 16, 32 + insets.bottom),
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: ClampingScrollPhysics(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _bottom(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _bar(context),
        Flexible(
          child: _list(
            padding: EdgeInsets.fromLTRB(
              16,
              16,
              16,
              24 + MediaQuery.paddingOf(context).bottom,
            ),
            shrinkWrap: true,
          ),
        ),
      ],
    ),
  );

  /// Cancel, the title and the prominent button, as in an iOS navigation
  /// bar. Its text grows with the system's font size up to one and a half
  /// times, so the title still has room between the buttons.
  PreferredSizeWidget _bar(
    BuildContext context, {
    double top = 0,
    bool draggable = false,
  }) {
    final palette = context.palette;
    const most = 1.5;
    final scaler = MediaQuery.textScalerOf(context).clamp(maxScaleFactor: most);
    final height = math.max(56.0, scaler.scale(17) + 32);
    Widget bar = Container(
      padding: EdgeInsets.only(top: top, left: 4, right: 4),
      decoration: BoxDecoration(
        color: palette.sidebar,
        border: Border(bottom: BorderSide(color: palette.separator)),
      ),
      child: SizedBox(
        height: height,
        child: NavigationToolbar(
          middleSpacing: 8,
          leading: widget.action == null
              ? null
              : TextButton(
                  onPressed: _close,
                  child: const Text(
                    'Cancel',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w400),
                  ),
                ),
          middle: _Title(widget.title, size: 17, maxLines: 1),
          trailing: TextButton(
            onPressed: _primary,
            child: Text(
              widget.action ?? 'Done',
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ),
    );
    if (draggable) {
      bar = GestureDetector(
        onVerticalDragUpdate: (details) => _dragBy(details.delta.dy),
        onVerticalDragEnd: (details) =>
            _dragEnd(details.velocity.pixelsPerSecond.dy),
        child: bar,
      );
    }
    return PreferredSize(
      preferredSize: Size.fromHeight(top + height + 1),
      child: MediaQuery.withClampedTextScaling(
        maxScaleFactor: most,
        child: bar,
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title(this.text, {required this.size, this.maxLines});

  final String text;
  final double size;
  final int? maxLines;

  @override
  Widget build(BuildContext context) => Semantics(
    header: true,
    child: Text(
      text,
      maxLines: maxLines,
      overflow: maxLines == null ? null : TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: size,
        fontWeight: FontWeight.w700,
        color: context.palette.text,
      ),
    ),
  );
}

// --- The list ----------------------------------------------------------------

/// Rounded rows with separators between them, a header above and a caption
/// below that says what the rows do. An [error], when there is one, takes
/// the caption's place.
class SettingsGroup extends StatelessWidget {
  const SettingsGroup({
    super.key,
    required this.children,
    this.header,
    this.footer,
    this.error,
  });

  final List<Widget> children;
  final String? header;
  final String? footer;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final caption = error ?? footer;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (header case final header?)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
            child: Semantics(
              header: true,
              child: Text(
                header,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: palette.muted,
                ),
              ),
            ),
          ),
        // Material, not a decorated box: rows paint their pressed look on it.
        Material(
          color: palette.cell,
          clipBehavior: Clip.antiAlias,
          borderRadius: BorderRadius.circular(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (i, child) in children.indexed) ...[
                if (i > 0)
                  Divider(height: 1, indent: 16, color: palette.separator),
                child,
              ],
            ],
          ),
        ),
        if (caption != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
            child: Semantics(
              liveRegion: error != null,
              child: Text(
                caption,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: error != null ? palette.error : palette.muted,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// One row: a label with an optional line under it, a [value] on the
/// right, and whatever goes at the end. Long values shorten with an
/// ellipsis; the label keeps at least half the row.
class SettingsRow extends StatelessWidget {
  const SettingsRow({
    super.key,
    required this.label,
    this.detail,
    this.leading,
    this.value,
    this.trailing,
    this.onTap,
    this.color,
  });

  final String label;
  final String? detail;
  final Widget? leading;
  final String? value;
  final Widget? trailing;
  final VoidCallback? onTap;

  /// The label's color, when it isn't plain text.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 15, color: color ?? palette.text),
        ),
        if (detail case final detail?)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              detail,
              style: TextStyle(
                fontSize: 13,
                height: 1.35,
                color: palette.muted,
              ),
            ),
          ),
      ],
    );
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 44),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: LayoutBuilder(
            builder: (context, constraints) => Row(
              children: [
                if (leading case final leading?) ...[
                  leading,
                  const SizedBox(width: 12),
                ],
                if (value case final value?) ...[
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: constraints.maxWidth * 0.5,
                    ),
                    child: text,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      value,
                      textAlign: TextAlign.end,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 15, color: palette.muted),
                    ),
                  ),
                ] else
                  Expanded(child: text),
                if (trailing case final trailing?) ...[
                  const SizedBox(width: 8),
                  trailing,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A text field in a row: its label on the left, what's typed on the
/// right. With a [maxLength] a counter shows once fewer than ten
/// characters are left. Enter does what the sheet's prominent button does.
class TextFieldRow extends StatefulWidget {
  const TextFieldRow({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.maxLength,
    this.keyboardType,
    this.inputFormatters = const [],
    this.autofocus = false,
    this.autocorrect = true,
    this.enabled = true,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final int? maxLength;
  final TextInputType? keyboardType;
  final List<TextInputFormatter> inputFormatters;
  final bool autofocus;
  final bool autocorrect;
  final bool enabled;

  @override
  State<TextFieldRow> createState() => _TextFieldRowState();
}

class _TextFieldRowState extends State<TextFieldRow> {
  final _focus = FocusNode();

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final max = widget.maxLength;
    const none = InputBorder.none;
    return MergeSemantics(
      child: GestureDetector(
        // A tap on the label types in the field too.
        behavior: HitTestBehavior.opaque,
        onTap: _focus.requestFocus,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            child: LayoutBuilder(
              builder: (context, constraints) => Row(
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: constraints.maxWidth * 0.45,
                    ),
                    child: Text(
                      widget.label,
                      style: TextStyle(fontSize: 15, color: palette.text),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: widget.controller,
                      focusNode: _focus,
                      autofocus: widget.autofocus,
                      autocorrect: widget.autocorrect,
                      enabled: widget.enabled,
                      keyboardType: widget.keyboardType,
                      textInputAction: TextInputAction.done,
                      textAlign: TextAlign.end,
                      style: TextStyle(fontSize: 15, color: palette.text),
                      inputFormatters: [
                        if (max != null) LengthLimitingTextInputFormatter(max),
                        ...widget.inputFormatters,
                      ],
                      decoration: InputDecoration(
                        hintText: widget.hint,
                        isDense: true,
                        filled: false,
                        border: none,
                        enabledBorder: none,
                        focusedBorder: none,
                        disabledBorder: none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10,
                        ),
                      ),
                      onSubmitted: (_) => SettingsSheet.submit(context),
                    ),
                  ),
                  if (max != null)
                    ListenableBuilder(
                      listenable: widget.controller,
                      builder: (context, _) {
                        final used = widget.controller.text.characters.length;
                        if (max - used >= 10) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Text(
                            '$used/$max',
                            style: TextStyle(
                              fontSize: 13,
                              color: used >= max
                                  ? palette.error
                                  : palette.tertiary,
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A choice among a few: the label, what's chosen and a chevron; a tap
/// opens a menu of the [options], each a value and what it's called.
class PickerRow<T> extends StatelessWidget {
  const PickerRow({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<(T, String)> options;

  /// Null makes the row read-only.
  final ValueChanged<T>? onChanged;

  Future<void> _open(BuildContext context) async {
    final row = context.findRenderObject()! as RenderBox;
    final overlay =
        Overlay.of(context).context.findRenderObject()! as RenderBox;
    final at = row.localToGlobal(Offset.zero, ancestor: overlay) & row.size;
    final current = options.indexWhere((o) => o.$1 == value);
    // Indices, not values: a value may be null, as a menu dismissed is.
    final picked = await showMenu<int>(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromLTWH(at.right, at.top, 0, at.height),
        Offset.zero & overlay.size,
      ),
      initialValue: current < 0 ? null : current,
      items: [
        for (final (i, (_, name)) in options.indexed)
          CheckedPopupMenuItem(
            value: i,
            checked: i == current,
            child: Text(name, overflow: TextOverflow.ellipsis),
          ),
      ],
    );
    if (picked != null) onChanged?.call(options[picked].$1);
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final chosen = options.where((o) => o.$1 == value).firstOrNull;
    return Semantics(
      button: onChanged != null,
      child: SettingsRow(
        label: label,
        value: chosen?.$2 ?? '',
        color: onChanged == null ? palette.muted : null,
        trailing: Icon(Icons.unfold_more, size: 18, color: palette.tertiary),
        onTap: onChanged == null ? null : () => _open(context),
      ),
    );
  }
}

/// A setting that is on or off. Null [onChanged] shows it locked.
class SwitchRow extends StatelessWidget {
  const SwitchRow({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.detail,
  });

  final String label;
  final String? detail;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final onChanged = this.onChanged;
    return MergeSemantics(
      child: SettingsRow(
        label: label,
        detail: detail,
        color: onChanged == null ? context.palette.muted : null,
        onTap: onChanged == null ? null : () => onChanged(!value),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }
}

/// One of several choices, ticked when it's the one.
class CheckRow extends StatelessWidget {
  const CheckRow({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.detail,
    this.leading,
  });

  final String label;
  final String? detail;
  final Widget? leading;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    selected: selected,
    button: true,
    child: SettingsRow(
      label: label,
      detail: detail,
      leading: leading,
      onTap: onTap,
      trailing: Icon(
        Icons.check,
        size: 20,
        color: selected ? context.palette.accent : Colors.transparent,
      ),
    ),
  );
}

/// A row that does something: tinted, or red when it can't be undone.
/// Those go in a group of their own at the bottom.
class ButtonRow extends StatelessWidget {
  const ButtonRow({
    super.key,
    required this.label,
    required this.onTap,
    this.destructive = false,
  });

  final String label;
  final VoidCallback? onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Semantics(
      button: true,
      child: SettingsRow(
        label: label,
        onTap: onTap,
        color: onTap == null
            ? palette.tertiary
            : destructive
            ? palette.error
            : palette.accent,
      ),
    );
  }
}
