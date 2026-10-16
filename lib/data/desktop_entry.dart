// On Linux an AppImage is just a file: nothing puts it in the app menu or
// tells the system it opens wisetalk: links. Wisetalk does both itself,
// once per start (the file may have moved), so a server's web page can hand
// the app its address. When an AppImage manager (Gear Lever,
// AppImageLauncher) already made a menu entry, Wisetalk leaves the menu to
// it and opens the links through it. The manager copies the entry inside
// the AppImage (packaging/linux) once and keeps it when the AppImage updates
// itself, so an entry from an older Wisetalk lacks the window class, the
// link handler or the %u for the link: Wisetalk mends those lines in it
// rather than hiding a menu entry of its own, which GNOME would match the
// window to and refuse to pin (WLK-43).

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'language.dart';

const _id = 'net.wiseless.wisetalk';

/// The desktop entry that starts this Wisetalk, for notifications to name
/// the app by: Wisetalk's own, or the AppImage manager's that took over.
String desktopEntryId = _id;

Future<void> registerDesktopEntry() async {
  final image = Platform.environment['APPIMAGE'];
  final home = Platform.environment['HOME'];
  if (!Platform.isLinux || image == null || home == null) return;
  try {
    final data = Platform.environment['XDG_DATA_HOME'] ?? '$home/.local/share';
    final icon = File('$data/icons/hicolor/512x512/apps/$_id.png');
    if (!icon.existsSync()) {
      await icon.parent.create(recursive: true);
      final bytes = await rootBundle.load('assets/logo.png');
      await icon.writeAsBytes(bytes.buffer.asUint8List());
    }

    final entry = File('$data/applications/$_id.desktop');
    final others = _entriesFor(image, Directory('$data/applications'), entry);
    if (others.isNotEmpty) {
      // The one that already opens links, if the manager made several.
      final theirs = others.firstWhere(
        (f) => f.readAsLinesSync().any(
          (l) => l.startsWith('MimeType=') && l.contains(_scheme),
        ),
        orElse: () => others.first,
      );
      final mended = mendEntry(theirs.readAsStringSync());
      if (mended != null) await _write(theirs, mended);
      desktopEntryId = theirs.uri.pathSegments.last.replaceFirst(
        RegExp(r'\.desktop$'),
        '',
      );
      if (entry.existsSync()) await entry.delete();
      await _handleLinksWith(theirs);
      return;
    }
    // AppImageLauncher integrates the AppImage itself, a little later.
    final hidden =
        (Platform.environment['DESKTOPINTEGRATION'] ?? '').isNotEmpty;
    final text =
        '''[Desktop Entry]
Type=Application
Name=Wisetalk
${_comments()}
Exec=${_quote(image)} %u
Icon=$_id
Categories=Network;InstantMessaging;
Terminal=false
StartupWMClass=$_id
MimeType=x-scheme-handler/wisetalk;
${hidden ? 'NoDisplay=true\n' : ''}''';
    if (entry.existsSync() && entry.readAsStringSync() == text) return;
    await entry.parent.create(recursive: true);
    await _write(entry, text);
    await _handleLinksWith(entry);
  } catch (e) {
    // A read-only home, no xdg-utils: links just won't open the app.
    debugPrint('cannot register the desktop entry: $e');
  }
}

const _scheme = 'x-scheme-handler/wisetalk';

/// The entry's comment in every language the app speaks, English the
/// default. By language alone, as the app's texts are: any Portuguese reads
/// Brazilian, any Chinese Traditional.
String _comments() {
  final lines = <String>[];
  for (final language in languages.keys) {
    final key = language == 'en'
        ? 'Comment'
        : 'Comment[${localeOf(language).languageCode}]';
    lines.add('$key=${textsFor(language).desktopComment}');
  }
  return lines.join('\n');
}

/// Whole or not at all: a half-written entry would leave the menu broken.
Future<void> _write(File entry, String text) async {
  final draft = File('${entry.path}.new');
  await draft.writeAsString(text, flush: true);
  await draft.rename(entry.path);
}

/// [text], an AppImage manager's entry for Wisetalk, with what GNOME and
/// the links need: the window class, the link handler and a %u in Exec for
/// the link. Only those lines of the main group change; `null` when nothing
/// has to.
@visibleForTesting
String? mendEntry(String text) {
  final lines = text.split('\n');
  final start = lines.indexWhere((l) => l.trim() == '[Desktop Entry]');
  if (start < 0) return null;
  var end = lines.indexWhere((l) => l.startsWith('['), start + 1);
  if (end < 0) end = lines.length;
  // New lines go after the group's last one, before blank lines.
  var at = end;
  while (at > start + 1 && lines[at - 1].trim().isEmpty) {
    at--;
  }
  final added = <String>[];
  var changed = false;

  // [mend] gets the value, `null` when the line is missing, and returns
  // the value to have, `null` for no line.
  void set(String key, String? Function(String? value) mend) {
    final i = lines.indexWhere((l) => l.startsWith('$key='), start + 1);
    final present = i >= 0 && i < end;
    final value = present ? lines[i].substring(key.length + 1) : null;
    final mended = mend(value);
    if (mended == null || mended == value) return;
    if (present) {
      lines[i] = '$key=$mended';
    } else {
      added.add('$key=$mended');
    }
    changed = true;
  }

  set('StartupWMClass', (_) => _id);
  set('MimeType', (value) {
    if (value == null || value.isEmpty) return '$_scheme;';
    if (value.split(';').contains(_scheme)) return value;
    return value.endsWith(';') ? '$value$_scheme;' : '$value;$_scheme;';
  });
  set('Exec', (value) {
    // Any field code means the manager passes arguments on already.
    if (value == null || RegExp(r'%[uUfF]').hasMatch(value)) return value;
    return '$value %u';
  });
  if (!changed) return null;
  lines.insertAll(at, added);
  return lines.join('\n');
}

/// Makes [entry] the one that opens wisetalk: links.
Future<void> _handleLinksWith(File entry) async {
  await Process.run('xdg-mime', [
    'default',
    entry.uri.pathSegments.last,
    _scheme,
  ]);
  await Process.run('update-desktop-database', [entry.parent.path]);
}

/// Entries other than ours that start this AppImage, as AppImage managers
/// make them.
List<File> _entriesFor(String image, Directory folder, File ours) {
  try {
    return [
      for (final file in folder.listSync().whereType<File>())
        if (file.path.endsWith('.desktop') &&
            file.path != ours.path &&
            file.readAsLinesSync().any(
              (l) =>
                  (l.startsWith('Exec=') || l.startsWith('TryExec=')) &&
                  l.contains(image),
            ))
          file,
    ];
  } on FileSystemException {
    // Unreadable: assume nobody else made one.
    return const [];
  }
}

/// A path as the desktop entry spec wants it in Exec.
String _quote(String path) {
  final escaped = path.replaceAllMapped(RegExp(r'["`$\\]'), (m) => '\\${m[0]}');
  return '"$escaped"';
}
