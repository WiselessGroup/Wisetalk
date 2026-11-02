#!/usr/bin/env bash
# Builds dist/Wisetalk-<version>.apk: one APK for every phone, with arm64, arm
# and x86_64 in one file.
#
#   scripts/build-android.sh <version>
#
# Needs Flutter, rustup and the Android SDK with its NDK. Signs with the key in
# $ANDROID_KEYSTORE (base64 of the keystore) and $ANDROID_KEYSTORE_PASSWORD,
# and $ANDROID_KEY_PASSWORD when the key has a password of its own. Without
# them it signs with the debug key, and refuses to for a tag: phones would
# never accept updates signed with the real key on top of it.
set -euo pipefail
cd "$(dirname "$0")/.."

version=$1
base=${version%%-*}
IFS=. read -r major minor patch <<< "$base"

if [[ -n ${ANDROID_KEYSTORE:-} ]]; then
  umask 077
  base64 -d <<< "$ANDROID_KEYSTORE" > android/release.jks
  # The alias, read from the keystore itself.
  alias=$(keytool -list -keystore android/release.jks -storepass:env ANDROID_KEYSTORE_PASSWORD 2>/dev/null |
    sed -n 's/^\([^,]*\), .*PrivateKeyEntry.*/\1/p' | head -n 1)
  [[ -n $alias ]] || { echo "wrong password, or no key in the keystore" >&2; exit 1; }
  printf 'storeFile=release.jks\nstorePassword=%s\nkeyAlias=%s\nkeyPassword=%s\n' \
    "$ANDROID_KEYSTORE_PASSWORD" "$alias" "${ANDROID_KEY_PASSWORD:-$ANDROID_KEYSTORE_PASSWORD}" \
    > android/key.properties
  umask 022
elif [[ ${GITHUB_REF:-} == refs/tags/v* ]]; then
  echo "no ANDROID_KEYSTORE, refusing to release a debug-signed APK" >&2
  exit 1
fi

mkdir -p dist
flutter pub get --enforce-lockfile
flutter build apk --release --build-name="$base" \
  --build-number=$((major * 1000000 + minor * 1000 + patch)) \
  --dart-define=WISETALK_VERSION="$version" \
  --dart-define=WISETALK_SENTRY_DSN="${WISETALK_SENTRY_DSN:-}"
cp build/app/outputs/flutter-apk/app-release.apk "dist/Wisetalk-$version.apk"
