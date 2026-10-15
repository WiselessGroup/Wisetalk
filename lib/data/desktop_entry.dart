// On Linux an AppImage is just a file: nothing puts it in the app menu or
// tells the system it opens wisetalk: links. Wisetalk does both itself,
// once per start (the file may have moved), so a server's web page can hand
// the app its address. When an AppImage manager (Gear Lever,
// AppImageLauncher) already made a menu entry, Wisetalk leaves the menu to
// it: from the entry inside the AppImage (packaging/linux), that entry also
// opens the links. An older AppImage's entry doesn't, so Wisetalk's own
// stays for the links, out of the menu.

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

const _id = 'net.wiseless.wisetalk';

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
    final handler = others
        .where(
          (f) => f.readAsLinesSync().any(
            (l) => l.startsWith('MimeType=') && l.contains(_scheme),
          ),
        )
        .firstOrNull;
    if (handler != null) {
      if (entry.existsSync()) await entry.delete();
      await _handleLinksWith(handler);
      return;
    }
    final hidden =
        others.isNotEmpty ||
        (Platform.environment['DESKTOPINTEGRATION'] ?? '').isNotEmpty;
    final text =
        '''[Desktop Entry]
Type=Application
Name=Wisetalk
Comment=Voice and video chat for one community
Exec=${_quote(image)} %u
Icon=$_id
Categories=Network;InstantMessaging;
Terminal=false
StartupWMClass=$_id
MimeType=x-scheme-handler/wisetalk;
${hidden ? 'NoDisplay=true\n' : ''}''';
    if (entry.existsSync() && entry.readAsStringSync() == text) return;
    await entry.parent.create(recursive: true);
    // Whole or not at all: a half-written entry would leave the menu broken.
    final draft = File('${entry.path}.new');
    await draft.writeAsString(text, flush: true);
    await draft.rename(entry.path);
    await _handleLinksWith(entry);
  } catch (e) {
    // A read-only home, no xdg-utils: links just won't open the app.
    debugPrint('cannot register the desktop entry: $e');
  }
}

const _scheme = 'x-scheme-handler/wisetalk';

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
