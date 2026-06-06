#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
timestamp="$(date +%Y%m%d%H%M%S)"

codex_home="${CODEX_HOME:-$HOME/.codex}"
agents_home="${AGENTS_HOME:-$HOME/.agents}"
claude_home="${CLAUDE_HOME:-$HOME/.claude}"
data_dir="${HARETRAIL_DATA_DIR:-}"

dry_run=0
include_claude=0

skills=(
  task
  summary
  research
  doc-write
  debrief
  lessons
  postmortem
  contribution-log
)

usage() {
  cat <<'USAGE'
Usage: install-connectors.sh [options]

Options:
  --dry-run             Print planned changes without writing files.
  --include-claude      Also link source skill folders into ~/.claude/skills.
  --data-dir PATH       Data repo root. Overrides HARETRAIL_DATA_DIR for validation output.
  --codex-home PATH     Codex home directory. Default: $CODEX_HOME or ~/.codex.
  --agents-home PATH    Agents home directory. Default: $AGENTS_HOME or ~/.agents.
  --claude-home PATH    Claude home directory. Default: $CLAUDE_HOME or ~/.claude.
  -h, --help            Show this help.

Notes:
  - This script installs symlinks to reusable source skill folders.
  - It does not copy private data and does not write inside the data repo.
  - Claude support is source-link only until tool-specific wrappers are added.
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)
      dry_run=1
      shift
      ;;
    --include-claude)
      include_claude=1
      shift
      ;;
    --data-dir)
      data_dir="${2:-}"
      shift 2
      ;;
    --codex-home)
      codex_home="${2:-}"
      shift 2
      ;;
    --agents-home)
      agents_home="${2:-}"
      shift 2
      ;;
    --claude-home)
      claude_home="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      printf 'Unknown option: %s\n\n' "$1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

run() {
  if [[ "$dry_run" -eq 1 ]]; then
    printf '[dry-run] %q' "$1"
    shift
    for arg in "$@"; do
      printf ' %q' "$arg"
    done
    printf '\n'
  else
    "$@"
  fi
}

note() {
  printf '%s\n' "$*"
}

require_source_skill() {
  local skill="$1"
  local source="$repo_root/skills/$skill"

  if [[ ! -f "$source/SKILL.md" ]]; then
    printf 'Missing skill source: %s\n' "$source" >&2
    exit 1
  fi
}

backup_if_needed() {
  local path="$1"

  if [[ -e "$path" && ! -L "$path" ]]; then
    local backup_path="${path}.bak.${timestamp}"
    run mv "$path" "$backup_path"
    note "Backed up $path -> $backup_path"
  fi
}

link_path() {
  local source="$1"
  local target="$2"

  backup_if_needed "$target"
  run ln -sfn "$source" "$target"
  note "Linked $target -> $source"
}

validate_data_dir() {
  if [[ -z "$data_dir" ]]; then
    note "HARETRAIL_DATA_DIR is not set. Skills will require current workspace or explicit host config to resolve {data-repo}."
    return
  fi

  if [[ ! -d "$data_dir" ]]; then
    printf 'Data dir does not exist: %s\n' "$data_dir" >&2
    exit 1
  fi

  if [[ ! -d "$data_dir/work-artifacts" || ! -f "$data_dir/LESSONS.md" ]]; then
    note "Warning: data dir exists but does not look like a full HARE Trail data repo: $data_dir"
    note "Expected at least: work-artifacts/ and LESSONS.md"
  else
    note "Data repo detected: $data_dir"
  fi
}

for skill in "${skills[@]}"; do
  require_source_skill "$skill"
done

validate_data_dir

run mkdir -p "$codex_home/skills" "$agents_home/skills"

for skill in "${skills[@]}"; do
  link_path "$repo_root/skills/$skill" "$codex_home/skills/$skill"
  link_path "$repo_root/skills/$skill" "$agents_home/skills/$skill"
done

if [[ "$include_claude" -eq 1 ]]; then
  run mkdir -p "$claude_home/skills"
  for skill in "${skills[@]}"; do
    link_path "$repo_root/skills/$skill" "$claude_home/skills/$skill"
  done
  note "Claude source links installed. Tool-specific Claude wrappers are not validated yet."
else
  note "Skipped Claude links. Use --include-claude to install source links explicitly."
fi

note "Installed HARE Trail connectors from $repo_root"
note "Data repo resolution remains runtime-configured via HARETRAIL_DATA_DIR, current workspace, or host-tool config."
