#!/usr/bin/env bash
#
# run-smoke.sh — build and run the HARE Trail clean-checkout smoke container.
#
# Works with any Docker-compatible runtime, including Colima (the active
# `docker` context is used as-is). The container clones a clean checkout and
# runs test/smoke/container-smoke.sh against disposable paths.
#
# Usage:
#   test/smoke/run-smoke.sh              # clone the local working repo (committed state)
#   test/smoke/run-smoke.sh --github     # clone the public GitHub repo instead
#   test/smoke/run-smoke.sh --ref BRANCH # with --github, check out a specific ref
#
# Notes:
#   - --github needs network from the container (Colima provides it).
#   - The host repo is mounted read-only; the test never writes into it.

set -euo pipefail

here="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd -- "$here/../.." && pwd)"

image="haretrail-smoke:latest"
github_url="https://github.com/fleytman/haretrail.git"

use_github=0
ref=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --github) use_github=1; shift ;;
    --ref) ref="${2:?--ref needs a value}"; shift 2 ;;
    --image) image="${2:?--image needs a value}"; shift 2 ;;
    -h|--help)
      sed -n '2,20p' "$0" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    *) printf 'Unknown option: %s\n' "$1" >&2; exit 2 ;;
  esac
done

if ! docker info >/dev/null 2>&1; then
  printf 'docker is not reachable. If you use Colima, start it first:\n' >&2
  printf '  colima start\n' >&2
  exit 1
fi

printf 'Docker context: %s\n' "$(docker context show 2>/dev/null || echo default)"
printf 'Building smoke image: %s\n' "$image"
docker build -t "$image" "$here"

printf 'Running smoke...\n\n'
if [[ "$use_github" -eq 1 ]]; then
  args=(-e SRC="$github_url")
  [[ -n "$ref" ]] && args+=(-e REF="$ref")
  docker run --rm "${args[@]}" "$image"
else
  docker run --rm -v "$repo_root":/src:ro "$image"
fi
