#!/usr/bin/env bash
# Builds, in dist/: Wisetalk-<version>-x86_64.AppImage with its .zsync, and
# Velopack's update packages and feed. The release before supplies a delta.
#
#   scripts/build-linux.sh <version>
#
# Needs Flutter with the Linux desktop toolchain, rustup, vpk, squashfs-tools,
# zstd and zsync. Build on the oldest system you want to run on: an AppImage
# needs the same or a newer glibc.
set -euo pipefail
cd "$(dirname "$0")/.."

version=$1
base=${version%%-*}
repo=https://github.com/WiselessGroup/Wisetalk
image=Wisetalk-$version-x86_64.AppImage
# Gear Lever looks for the newest .zsync matching this on GitHub, and takes
# the AppImage named the same without the suffix.
update_info="gh-releases-zsync|WiselessGroup|Wisetalk|latest|Wisetalk-*-x86_64.AppImage.zsync"

rm -rf dist
mkdir -p dist
flutter pub get --enforce-lockfile
flutter build linux --release --build-name="$base" \
  --dart-define=WISETALK_SENTRY_DSN="${WISETALK_SENTRY_DSN:-}"

# Our own AppDir, which vpk takes as it is and adds its updater to: its
# desktop entry names the window the app opens and the wisetalk: links it
# handles, so AppImage managers (Gear Lever) make one working entry. vpk
# recognizes it by the .AppDir in its name.
app=build/Wisetalk.AppDir
rm -rf "$app"
mkdir -p "$app/usr/bin" "$app/usr/share/metainfo" \
  "$app/usr/share/icons/hicolor/512x512/apps"
cp -a build/linux/x64/release/bundle/. "$app/usr/bin/"
cp packaging/linux/AppRun "$app/AppRun"
sed "s/@VERSION@/$version/" packaging/linux/net.wiseless.wisetalk.desktop \
  > "$app/net.wiseless.wisetalk.desktop"
sed "s/@VERSION@/$version/; s/@DATE@/$(date -u +%F)/" \
  packaging/linux/net.wiseless.wisetalk.metainfo.xml \
  > "$app/usr/share/metainfo/net.wiseless.wisetalk.metainfo.xml"
for icon in net.wiseless.wisetalk.png .DirIcon \
  usr/share/icons/hicolor/512x512/apps/net.wiseless.wisetalk.png; do
  cp packaging/linux/wisetalk.png "$app/$icon"
done

scripts/set-update-info.sh "$update_info"
vpk download github --repoUrl "$repo" --channel linux -o dist ${GH_TOKEN:+--token "$GH_TOKEN"} \
  || echo "no release to make a delta from"
vpk pack --packId Wisetalk --packVersion "$version" --channel linux \
  --packDir "$app" --mainExe wisetalk --packTitle Wisetalk -o dist
mv dist/Wisetalk.AppImage "dist/$image"

# Nothing ships unless Gear Lever and Velopack would both be right about it.
# It compares its file's SHA-1 with the .zsync, so an update through Velopack
# has to leave exactly the published file, and the string has to survive it.
readelf -p .upd_info "dist/$image" | grep -qF "$update_info" \
  || { echo "the update string didn't reach the image" >&2; exit 1; }
unzip -p "dist/Wisetalk-$version-linux-full.nupkg" lib/app/Wisetalk.AppImage | cmp - "dist/$image" \
  || { echo "the image in the update package differs from the published one" >&2; exit 1; }

# Last: the .zsync records the finished image's hash.
(cd dist && zsyncmake -u "$image" -o "$image.zsync" "$image")
