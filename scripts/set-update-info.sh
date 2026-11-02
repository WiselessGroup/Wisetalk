#!/usr/bin/env bash
# Writes the AppImage update string into the runtime vpk builds images from.
#
#   scripts/set-update-info.sh '<update string>'
#
# Gear Lever reads the string from the image's .upd_info section. vpk has no
# option for it, and a release holds the image twice: the file itself and the
# copy in the .nupkg that Velopack installs. Writing it here, before vpk
# packs, puts it in both, byte for byte, with vpk's hashes and feed covering
# the result. Patching the finished file would lose the string at the first
# update through Velopack.
set -euo pipefail

info=$1
shopt -s nullglob
runtimes=("$HOME"/.dotnet/tools/.store/vpk/*/vpk/*/vendor/appimagekit-runtime-x86_64)
[[ ${#runtimes[@]} -eq 1 ]] || { echo "expected one vpk runtime, found ${#runtimes[@]}" >&2; exit 1; }
runtime=${runtimes[0]}

read -r offset size < <(LC_ALL=C readelf -S -W "$runtime" |
  sed -n 's/.*\.upd_info *PROGBITS *[0-9a-f]* *\([0-9a-f]*\) *\([0-9a-f]*\) .*/\1 \2/p')
[[ -n ${offset:-} ]] || { echo "no .upd_info section in $runtime" >&2; exit 1; }
offset=$((16#$offset))
size=$((16#$size))
[[ ${#info} -lt $size ]] || { echo "the update string doesn't fit in $size bytes" >&2; exit 1; }

head -c "$size" /dev/zero | dd of="$runtime" bs=1 seek="$offset" conv=notrunc status=none
printf '%s' "$info" | dd of="$runtime" bs=1 seek="$offset" conv=notrunc status=none
