#!/bin/sh
# Attaches files to the Forgejo release of the current tag, creating the
# release first if no other job has yet. Notes come from the tag's section
# in CHANGELOG.md; versions with a hyphen (1.0.0-beta.1) are prereleases.
# Usage: scripts/release-upload.sh <file>...   (needs TOKEN and the
# GITHUB_* variables Forgejo Actions sets)
set -eu

api="$GITHUB_SERVER_URL/api/v1/repos/$GITHUB_REPOSITORY"
tag=$GITHUB_REF_NAME
version=${tag#v}

call() {
    curl -sSf -H "Authorization: token $TOKEN" "$@"
}

release_id() {
    call "$api/releases/tags/$tag" 2>/dev/null | jq -r .id
}

id=$(release_id || true)
if [ -z "$id" ] || [ "$id" = null ]; then
    notes=$(awk -v v="$version" '
        $0 ~ "^## " v "( |$)" { on = 1; next }
        on && /^## / { exit }
        on { print }' CHANGELOG.md 2>/dev/null || true)
    case $version in *-*) pre=true ;; *) pre=false ;; esac
    body=$(jq -n --arg tag "$tag" --arg name "Wisetalk $version" --arg notes "$notes" \
        --argjson pre "$pre" '{tag_name: $tag, name: $name, body: $notes, prerelease: $pre}')
    # Another job may create it at the same moment; then take theirs.
    id=$(call -H "Content-Type: application/json" -d "$body" "$api/releases" | jq -r .id) \
        || id=$(release_id)
fi

for file in "$@"; do
    name=$(basename "$file")
    call -F "attachment=@$file" "$api/releases/$id/assets?name=$name" >/dev/null
    echo "attached $name to $tag"
done
