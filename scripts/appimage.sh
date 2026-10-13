#!/bin/sh
# Packs the release bundle of `flutter build linux --release` into an
# AppImage: dist/Wisetalk-<version>-x86_64.AppImage.
# Usage: scripts/appimage.sh <version> [appimagetool]
set -eu

version=$1
tool=${2:-appimagetool}
bundle=build/linux/x64/release/bundle
app=build/AppDir

test -x "$bundle/wisetalk" || { echo "build the release bundle first" >&2; exit 1; }
rm -rf "$app"
mkdir -p "$app/usr/bin" dist
cp -r "$bundle"/. "$app/usr/bin/"
cp packaging/linux/wisetalk.desktop "$app/"
cp packaging/linux/wisetalk.png "$app/"
mkdir -p "$app/usr/share/icons/hicolor/512x512/apps" "$app/usr/share/applications"
cp packaging/linux/wisetalk.png "$app/usr/share/icons/hicolor/512x512/apps/"
cp packaging/linux/wisetalk.desktop "$app/usr/share/applications/"
cat > "$app/AppRun" <<'RUN'
#!/bin/sh
here=$(dirname "$(readlink -f "$0")")
exec "$here/usr/bin/wisetalk" "$@"
RUN
chmod +x "$app/AppRun"

# No FUSE in containers: let the tool unpack itself instead of mounting.
APPIMAGE_EXTRACT_AND_RUN=1 ARCH=x86_64 "$tool" --no-appstream "$app" \
    "dist/Wisetalk-$version-x86_64.AppImage"
