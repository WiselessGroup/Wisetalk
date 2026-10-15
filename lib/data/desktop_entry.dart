// On Linux an AppImage is just a file: nothing puts it in the app menu or
// tells the system it opens wisetalk: links. Wisetalk does both itself,
// once per start (the file may have moved), so a server's web page can hand
// the app its address. When an AppImage manager (Gear Lever,
// AppImageLauncher) already made a menu entry, Wisetalk's own stays out of
// the menu and only opens the links.

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
    final hidden = _integrated(image, Directory('$data/applications'), entry);
    final text =
        '''[Desktop Entry]
Type=Application
Name=Wisetalk
Comment=Voice and video chat for one community
Exec=${_quote(image)} %u
Icon=$_id
Categories=Network;InstantMessaging;AudioVideo;
Terminal=false
StartupWMClass=$_id
MimeType=x-scheme-handler/wisetalk;
${hidden ? 'NoDisplay=true\n' : ''}''';
    if (entry.existsSync() && entry.readAsStringSync() == text) return;
    await entry.parent.create(recursive: true);
    await entry.writeAsString(text);
    await Process.run('xdg-mime', [
      'default',
      '$_id.desktop',
      'x-scheme-handler/wisetalk',
    ]);
    await Process.run('update-desktop-database', [entry.parent.path]);
  } catch (e) {
    // A read-only home, no xdg-utils: links just won't open the app.
    debugPrint('cannot register the desktop entry: $e');
  }
}

/// Whether something else put this AppImage in the app menu: managers
/// start it with DESKTOPINTEGRATION set, and their entries name its path.
bool _integrated(String image, Directory folder, File ours) {
  if ((Platform.environment['DESKTOPINTEGRATION'] ?? '').isNotEmpty) {
    return true;
  }
  try {
    for (final file in folder.listSync().whereType<File>()) {
      if (!file.path.endsWith('.desktop') || file.path == ours.path) continue;
      final lines = file.readAsLinesSync();
      if (lines.any(
        (l) =>
            (l.startsWith('Exec=') || l.startsWith('TryExec=')) &&
            l.contains(image),
      )) {
        return true;
      }
    }
  } on FileSystemException {
    // Unreadable: assume nobody else did it.
  }
  return false;
}

/// A path as the desktop entry spec wants it in Exec.
String _quote(String path) {
  final escaped = path.replaceAllMapped(RegExp(r'["`$\\]'), (m) => '\\${m[0]}');
  return '"$escaped"';
}
