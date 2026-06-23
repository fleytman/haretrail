#!/usr/bin/env bash
#
# run-e2e.sh — build and run the HARE Trail runtime skill-loading e2e.
#
# This launches REAL agent CLIs that make live, paid API calls. Auth tokens are
# read from the environment and forwarded into the container BY NAME only; no
# secret value is printed and no token reference is hardcoded here.
#
#   export OPENAI_API_KEY=...            # codex
#   export CLAUDE_CODE_OAUTH_TOKEN=...   # claude (or ANTHROPIC_API_KEY)
#   test/e2e/run-e2e.sh
#
# Optional: a secret manager can inject the variables at run time instead of
# exporting them, e.g. with 1Password:  op run -- test/e2e/run-e2e.sh
#
# Only these tokens are forwarded into the container; nothing else leaves the host.
#
# Options:
#   --codex-only / --claude-only   run a single agent
#   --github [--ref REF]           test the published repo instead of local tree
#   --build-only                   build the image, do not run
#   --image NAME                   image tag (default haretrail-e2e:latest)

set -euo pipefail

here="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd -- "$here/../.." && pwd)"

image="haretrail-e2e:latest"
github_url="https://github.com/fleytman/haretrail.git"
tools="codex,claude"
use_github=0
ref=""
build_only=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --codex-only)  tools="codex"; shift ;;
    --claude-only) tools="claude"; shift ;;
    --github)      use_github=1; shift ;;
    --ref)         ref="${2:?--ref needs a value}"; shift 2 ;;
    --build-only)  build_only=1; shift ;;
    --image)       image="${2:?--image needs a value}"; shift 2 ;;
    -h|--help)     sed -n '2,24p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) printf 'Unknown option: %s\n' "$1" >&2; exit 2 ;;
  esac
done

if ! docker info >/dev/null 2>&1; then
  printf 'docker is not reachable. With Colima: colima start\n' >&2
  exit 1
fi

printf 'Docker context: %s\n' "$(docker context show 2>/dev/null || echo default)"
printf 'Building e2e image: %s\n' "$image"
docker build -t "$image" "$here"

if [[ "$build_only" -eq 1 ]]; then
  printf 'Built %s (build-only)\n' "$image"
  exit 0
fi

run_args=(--rm -e "E2E_TOOLS=$tools")

# Forward tokens by name only (values come from the environment, e.g. op run).
if [[ -n "${OPENAI_API_KEY:-}" ]]; then run_args+=(-e OPENAI_API_KEY); fi
if [[ -n "${CLAUDE_CODE_OAUTH_TOKEN:-}" ]]; then run_args+=(-e CLAUDE_CODE_OAUTH_TOKEN); fi
if [[ -n "${ANTHROPIC_API_KEY:-}" ]]; then run_args+=(-e ANTHROPIC_API_KEY); fi

# Warn (do not fail) if a selected tool has no token; the container skips it.
case ",$tools," in *,codex,*) [[ -z "${OPENAI_API_KEY:-}" ]] && printf 'note: OPENAI_API_KEY not set; codex will be skipped\n' ;; esac
case ",$tools," in *,claude,*) [[ -z "${CLAUDE_CODE_OAUTH_TOKEN:-}${ANTHROPIC_API_KEY:-}" ]] && printf 'note: no Claude token set; claude will be skipped\n' ;; esac

printf 'Running e2e (live API calls)...\n\n'
if [[ "$use_github" -eq 1 ]]; then
  run_args+=(-e SRC="$github_url")
  [[ -n "$ref" ]] && run_args+=(-e REF="$ref")
  docker run "${run_args[@]}" "$image"
else
  run_args+=(-v "$repo_root":/src:ro)
  docker run "${run_args[@]}" "$image"
fi
