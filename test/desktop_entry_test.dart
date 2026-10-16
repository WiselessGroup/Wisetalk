import 'package:flutter_test/flutter_test.dart';
import 'package:wisetalk/data/desktop_entry.dart';

void main() {
  // What Gear Lever kept from 0.3.1 after the AppImage updated itself.
  const gearLever = '''[Desktop Entry]
Type=Application
Name=Wisetalk
Exec="/home/egor/AppImages/wisetalk.appimage"
Icon=/home/egor/.local/share/icons/wisetalk.png
StartupWMClass=Wisetalk
X-AppImage-Version=0.3.1

[Desktop Action Remove]
Name=Remove
Exec=gearlever --remove "/home/egor/AppImages/wisetalk.appimage"
''';

  test('an old manager entry gets the window class, links and %u', () {
    expect(mendEntry(gearLever), '''[Desktop Entry]
Type=Application
Name=Wisetalk
Exec="/home/egor/AppImages/wisetalk.appimage" %u
Icon=/home/egor/.local/share/icons/wisetalk.png
StartupWMClass=net.wiseless.wisetalk
X-AppImage-Version=0.3.1
MimeType=x-scheme-handler/wisetalk;

[Desktop Action Remove]
Name=Remove
Exec=gearlever --remove "/home/egor/AppImages/wisetalk.appimage"
''');
  });

  test('a mended entry stays as it is', () {
    expect(mendEntry(mendEntry(gearLever)!), isNull);
  });

  test('other link handlers and field codes are kept', () {
    const entry = '''[Desktop Entry]
Name=Wisetalk
Exec=/opt/wisetalk.AppImage %U
MimeType=x-scheme-handler/other
StartupWMClass=net.wiseless.wisetalk''';
    expect(mendEntry(entry), '''[Desktop Entry]
Name=Wisetalk
Exec=/opt/wisetalk.AppImage %U
MimeType=x-scheme-handler/other;x-scheme-handler/wisetalk;
StartupWMClass=net.wiseless.wisetalk''');
  });

  test('not a desktop entry: left alone', () {
    expect(mendEntry('Exec=whatever'), isNull);
  });
}
