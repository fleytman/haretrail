#!/usr/bin/env bash
#
# Image-baked bootstrap for the e2e container. Materializes a clean checkout
# into /work/haretrail, then runs that checkout's container-e2e.sh.
#
#   SRC = remote URL or local path (default /src, the read-only bind mount)
#   REF = optional branch/tag for remote clones
#
# Mirrors test/smoke/bootstrap.sh: remote SRC is cloned (pure published state),
# local SRC copies tracked + untracked-but-not-ignored files so local edits can
# be tested before they are committed.

set -euo pipefail

src="${SRC:-/src}"
ref="${REF:-}"
dest=/work/haretrail

git config --global --add safe.directory '*'
rm -rf "$dest"
mkdir -p "$dest"

case "$src" in
  http://*|https://*|git@*|*.git)
    if [[ -n "$ref" ]]; then
      git clone -q --branch "$ref" "$src" "$dest"
    else
      git clone -q "$src" "$dest"
    fi
    ;;
  *)
    if [[ ! -d "$src/.git" ]]; then
      printf 'Local source %s is not a git repo\n' "$src" >&2
      exit 1
    fi
    git -C "$src" ls-files -z --cached --others --exclude-standard \
      | tar --null -C "$src" -T - -cf - \
      | tar -C "$dest" -xf -
    ;;
esac

if [[ ! -f "$dest/test/e2e/container-e2e.sh" ]]; then
  printf 'Checkout has no test/e2e/container-e2e.sh (src=%s)\n' "$src" >&2
  exit 1
fi

exec bash "$dest/test/e2e/container-e2e.sh"
