#!/usr/bin/env bash
# The version a CI build carries: 0.7.0 for the tag v0.7.0, the version in
# pubspec.yaml with -dev.<commit> for anything else.
if [[ ${GITHUB_REF:-} == refs/tags/v* ]]; then
  echo "${GITHUB_REF_NAME#v}"
else
  echo "$(sed -n 's/^version: \([^+]*\).*/\1/p' "$(dirname "$0")/../pubspec.yaml")-dev.$(git rev-parse --short=7 HEAD)"
fi
