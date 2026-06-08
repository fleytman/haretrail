#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
timestamp="$(date +%Y%m%d%H%M%S)"

codex_home="${CODEX_HOME:-$HOME/.codex}"
agents_home="${AGENTS_HOME:-$HOME/.agents}"
claude_home="${CLAUDE_HOME:-$HOME/.claude}"
data_dir="${HARETRAIL_DATA_DIR:-}"
config_dir="${HARETRAIL_CONFIG_DIR:-$HOME/.haretrail}"
config_file=""

dry_run=0
include_claude=0
include_agents=0
install_mode="source"
write_config=0

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
  --include-agents      Also install into ~/.agents/skills. Off by default because some tools also scan this root and may show duplicate skills.
  --include-claude      Also link source skill folders into ~/.claude/skills.
  --mode MODE           Connector mode: source or wrapper. Default: source.
  --write-config        Write local config.env under ~/.haretrail or --config-dir.
  --data-dir PATH       Data repo root. Overrides HARETRAIL_DATA_DIR for validation output.
  --config-dir PATH     Local config directory. Default: $HARETRAIL_CONFIG_DIR or ~/.haretrail.
  --codex-home PATH     Codex home directory. Default: $CODEX_HOME or ~/.codex.
  --agents-home PATH    Agents home directory. Default: $AGENTS_HOME or ~/.agents.
  --claude-home PATH    Claude home directory. Default: $CLAUDE_HOME or ~/.claude.
  -h, --help            Show this help.

Notes:
  - This script installs symlinks to reusable source skill folders.
  - Wrapper mode installs small local SKILL.md files that point to canonical source skills.
  - It does not copy private data and does not write inside the data repo.
  - Claude source links or wrappers are installed only with --include-claude.
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
    --include-agents)
      include_agents=1
      shift
      ;;
    --mode)
      install_mode="${2:-}"
      shift 2
      ;;
    --write-config)
      write_config=1
      shift
      ;;
    --data-dir)
      data_dir="${2:-}"
      shift 2
      ;;
    --config-dir)
      config_dir="${2:-}"
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

config_file="$config_dir/config.env"

if [[ "$install_mode" != "source" && "$install_mode" != "wrapper" ]]; then
  printf 'Invalid --mode: %s\nExpected: source or wrapper\n' "$install_mode" >&2
  exit 2
fi

if [[ -n "$data_dir" && -d "$data_dir" ]]; then
  data_dir="$(cd -- "$data_dir" && pwd)"
fi

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

write_file() {
  local path="$1"
  local content="$2"

  if [[ "$dry_run" -eq 1 ]]; then
    printf '[dry-run] write %s\n' "$path"
  else
    printf '%s\n' "$content" > "$path"
  fi
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

prepare_wrapper_dir() {
  local target="$1"

  if [[ -L "$target" ]]; then
    run rm "$target"
  elif [[ -e "$target" && ! -f "$target/.haretrail-wrapper" ]]; then
    local backup_path="${target}.bak.${timestamp}"
    run mv "$target" "$backup_path"
    note "Backed up $target -> $backup_path"
  fi

  run mkdir -p "$target"
}

skill_title() {
  local skill="$1"

  case "$skill" in
    doc-write)
      printf 'Doc Write'
      ;;
    contribution-log)
      printf 'Contribution Log'
      ;;
    summary)
      printf 'Summary'
      ;;
    research)
      printf 'Research'
      ;;
    debrief)
      printf 'Debrief'
      ;;
    lessons)
      printf 'Lessons'
      ;;
    postmortem)
      printf 'Postmortem'
      ;;
    task)
      printf 'Task'
      ;;
    *)
      printf '%s' "$skill"
      ;;
  esac
}

install_wrapper() {
  local skill="$1"
  local target="$2"
  local source="$repo_root/skills/$skill/SKILL.md"
  local title

  title="$(skill_title "$skill")"
  prepare_wrapper_dir "$target"

  write_file "$target/.haretrail-wrapper" "generated-by=haretrail-install-connectors"
  write_file "$target/SKILL.md" "---
name: $skill
description: \"Thin local HARE Trail wrapper for $skill. Loads canonical workflow from $source and uses data repo $data_dir.\"
---

# $title

This is a generated local wrapper. Do not edit it as source of truth.

Canonical workflow:

\`\`\`text
$source
\`\`\`

Local runtime context:

\`\`\`text
HARETRAIL_SYSTEM_DIR=$repo_root
HARETRAIL_DATA_DIR=$data_dir
HARETRAIL_CONFIG=$config_file
\`\`\`

Before acting:

- Read the canonical workflow above.
- Treat \`$repo_root\` as the reusable system repo.
- Treat \`$data_dir\` as the default private data repo.
- Resolve any \`{data-repo}\` placeholder in the canonical workflow to \`$data_dir\`.
- Do not copy private data into the system repo.
- Follow the current workspace's own instructions when editing non-HARE Trail project files.
"
  note "Generated wrapper $target -> $source"
}

write_local_config() {
  run mkdir -p "$config_dir"

  if [[ -e "$config_file" && ! -f "$config_file" ]]; then
    local backup_path="${config_file}.bak.${timestamp}"
    run mv "$config_file" "$backup_path"
    note "Backed up $config_file -> $backup_path"
  fi

  write_file "$config_file" "# HARE Trail local config
# Generated by scripts/install-connectors.sh

HARETRAIL_SYSTEM_DIR=$repo_root
HARETRAIL_DATA_DIR=$data_dir
"
  note "Wrote local config: $config_file"
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

if [[ "$install_mode" == "wrapper" && -z "$data_dir" ]]; then
  printf 'Wrapper mode requires --data-dir or HARETRAIL_DATA_DIR.\n' >&2
  exit 2
fi

if [[ "$write_config" -eq 1 && -z "$data_dir" ]]; then
  printf '%s\n' '--write-config requires --data-dir or HARETRAIL_DATA_DIR.' >&2
  exit 2
fi

if [[ "$write_config" -eq 1 ]]; then
  write_local_config
fi

run mkdir -p "$codex_home/skills"

for skill in "${skills[@]}"; do
  if [[ "$install_mode" == "wrapper" ]]; then
    install_wrapper "$skill" "$codex_home/skills/$skill"
  else
    link_path "$repo_root/skills/$skill" "$codex_home/skills/$skill"
  fi
done

if [[ "$include_agents" -eq 1 ]]; then
  run mkdir -p "$agents_home/skills"
  for skill in "${skills[@]}"; do
    if [[ "$install_mode" == "wrapper" ]]; then
      install_wrapper "$skill" "$agents_home/skills/$skill"
    else
      link_path "$repo_root/skills/$skill" "$agents_home/skills/$skill"
    fi
  done
  note "Agents connectors installed in $install_mode mode."
else
  note "Skipped agents connectors. Use --include-agents only when the target tool requires ~/.agents/skills and does not also scan ~/.codex/skills."
fi

if [[ "$include_claude" -eq 1 ]]; then
  run mkdir -p "$claude_home/skills"
  for skill in "${skills[@]}"; do
    if [[ "$install_mode" == "wrapper" ]]; then
      install_wrapper "$skill" "$claude_home/skills/$skill"
    else
      link_path "$repo_root/skills/$skill" "$claude_home/skills/$skill"
    fi
  done
  note "Claude connectors installed in $install_mode mode."
else
  note "Skipped Claude connectors. Use --include-claude to install them explicitly."
fi

note "Installed HARE Trail connectors from $repo_root in $install_mode mode."
note "Data repo resolution remains runtime-configured via HARETRAIL_DATA_DIR, current workspace, or host-tool config."
