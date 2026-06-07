#!/usr/bin/env bash

set -euo pipefail

dry_run=0
git_init=0
target=""
name="HARE Trail Data"
language="en"
initial_task=""
task_title=""
task_kind="task"
with_source_dirs=0

usage() {
  cat <<'USAGE'
Usage: init-data-repo.sh --target PATH [options]

Create a minimal private HARE Trail data repository scaffold.

Options:
  --target PATH          Directory to initialize. Required.
  --name TEXT            Human-readable data repo name. Default: "HARE Trail Data".
  --language LANG        Scaffold language. Currently supported: en. Default: en.
  --initial-task SLUG    Also create work-artifacts/YYYY-MM-DD-SLUG.
  --task-title TEXT      Title for --initial-task. Default: SLUG.
  --task-kind KIND       task or research. Default: task.
  --with-source-dirs     Add sources/ and file-summaries/ to the initial task folder.
  --git-init             Run git init in the target directory.
  --dry-run              Print planned changes without writing files.
  -h, --help             Show this help.

Notes:
  - The script never copies private corpus.
  - The script does not write to real home directories.
  - Existing files are kept; missing files are created.
  - Windows support is intentionally deferred until after the first public demo.
USAGE
}

fail() {
  printf 'init-data-repo: %s\n' "$*" >&2
  exit 1
}

note() {
  printf '%s\n' "$*"
}

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

mkdir_dir() {
  local path="$1"

  if [[ -d "$path" ]]; then
    note "Exists: $path"
    return
  fi

  run mkdir -p "$path"
}

write_file() {
  local path="$1"

  if [[ -e "$path" ]]; then
    note "Exists, keep: $path"
    cat >/dev/null
    return
  fi

  if [[ "$dry_run" -eq 1 ]]; then
    printf '[dry-run] write %s\n' "$path"
    cat >/dev/null
    return
  fi

  mkdir -p "$(dirname -- "$path")"
  cat >"$path"
  note "Wrote: $path"
}

title_from_slug() {
  local slug="$1"
  local spaced="${slug//-/ }"
  printf '%s\n' "$spaced"
}

validate_slug() {
  local slug="$1"

  if [[ ! "$slug" =~ ^[A-Za-z0-9][A-Za-z0-9._-]*$ ]]; then
    fail "Invalid slug '$slug'. Use letters, numbers, dots, underscores or hyphens."
  fi
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target)
      target="${2:-}"
      shift 2
      ;;
    --name)
      name="${2:-}"
      shift 2
      ;;
    --language)
      language="${2:-}"
      shift 2
      ;;
    --initial-task)
      initial_task="${2:-}"
      shift 2
      ;;
    --task-title)
      task_title="${2:-}"
      shift 2
      ;;
    --task-kind)
      task_kind="${2:-}"
      shift 2
      ;;
    --with-source-dirs)
      with_source_dirs=1
      shift
      ;;
    --git-init)
      git_init=1
      shift
      ;;
    --dry-run)
      dry_run=1
      shift
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

[[ -n "$target" ]] || fail "--target is required"
[[ -n "$name" ]] || fail "--name cannot be empty"

case "$language" in
  en) ;;
  *) fail "Unsupported --language '$language'. Supported now: en." ;;
esac

case "$task_kind" in
  task|research) ;;
  *) fail "Unsupported --task-kind '$task_kind'. Use task or research." ;;
esac

target="${target%/}"

case "$target" in
  ""|"/"|"$HOME"|"$HOME/")
    fail "Refusing to initialize unsafe target: $target"
    ;;
esac

if [[ -n "$initial_task" ]]; then
  validate_slug "$initial_task"
  if [[ -z "$task_title" ]]; then
    task_title="$(title_from_slug "$initial_task")"
  fi
fi

created_date="$(date +%F)"
timestamp="$(date '+%Y-%m-%d %H:%M:%S %z')"

note "Initializing HARE Trail data repo scaffold: $target"
note "Language: $language"
note "Dry run: $dry_run"

mkdir_dir "$target"
mkdir_dir "$target/work-artifacts"
mkdir_dir "$target/notes"
mkdir_dir "$target/session-debriefs"
mkdir_dir "$target/postmortems"

write_file "$target/README.md" <<EOF
# $name

Created: $created_date
Updated: $created_date
Version: 0.1

## Purpose

This is a private HARE Trail data repository.

It stores real work artifacts, notes, session debriefs, lessons, postmortems and imported sources. Reusable system logic belongs in the public system repository, not here.

## Current Outputs

- Tracker: \`tracker.md\`
- Journal: \`journal.md\`
- Lessons: \`LESSONS.md\`
- Work artifacts: \`work-artifacts/\`
- Notes: \`notes/\`
- Session debriefs: \`session-debriefs/\`
- Postmortems: \`postmortems/\`

## Rules

- Keep private data in this repository.
- Keep reusable skills, templates, scripts and public docs in the HARE Trail system repository.
- Do not commit generated local connector files unless they are intentionally part of this data repo.
- Use the user's language or the active project language for working artifacts.

## Change Log

- $created_date v0.1: initialized HARE Trail data scaffold.
EOF

write_file "$target/tracker.md" <<EOF
# Tracker

Created: $created_date
Updated: $created_date
Version: 0.1

## Current Question

What durable work, notes and lessons should this data repository preserve?

## Current Decisions

- This repository is the private data layer.
- Reusable system logic stays outside this repository.

## What Contradicts The Current Model

- If reusable logic starts living here, the system/data boundary is broken.
- If real work lands in the system repository, publication safety is broken.

## Open Questions

- What projects or task folders should be migrated or created first?

## Next Steps

1. Create or link the first task folder under \`work-artifacts/\`.

## Change Log

- $created_date v0.1: started tracker.
EOF

write_file "$target/journal.md" <<EOF
# Journal

Created: $created_date
Updated: $created_date
Version: 0.1

## $created_date

### Entry 1

Timestamp: $timestamp
Agent: not recorded
Session ID: not recorded

Question at this moment:

- Initialize a private HARE Trail data repository.

Attempt:

- Created the minimal data repository scaffold.

Evidence:

- README, tracker, journal, lessons and core directories were created or already existed.

Result:

- The data repository is ready for private work artifacts.

Interpretation:

- Reusable system logic should remain outside this repository.

## Change Log

- $created_date v0.1: started journal.
EOF

write_file "$target/AGENTS.md" <<EOF
# AGENTS.md

This is a private HARE Trail data repository.

## Priority

- Preserve real work context, evidence, corrections and lessons.
- Keep private data here, not in the HARE Trail system repository.
- Follow local project instructions when work happens inside a specific project repository.

## Data Layout

- \`work-artifacts/\`: durable task and research folders.
- \`notes/\`: longer-lived notes.
- \`session-debriefs/\`: session-level learning.
- \`LESSONS.md\`: distilled lessons.
- \`postmortems/\`: incident-grade analyses.

## Language

Use the user's language or the active project language. If the target repository has explicit language rules, follow those rules for files written there.
EOF

write_file "$target/BASE.md" <<EOF
# BASE

Created: $created_date
Updated: $created_date
Version: 0.1

## Local Conventions

- Keep private work artifacts in this data repository.
- Keep reusable HARE Trail system logic in the system repository.
- Prefer readable markdown over hidden runtime memory.
- Record evidence for important claims.
EOF

write_file "$target/LESSONS.md" <<EOF
# LESSONS

Created: $created_date
Updated: $created_date
Version: 0.1

## Active Lessons

- Add lessons only when they are supported by evidence, user correction or verified outcome.
EOF

write_file "$target/.gitignore" <<'EOF'
.DS_Store
*.log
*.tmp
.haretrail/cache/
.codex/
.claude/
.agents/
EOF

if [[ -n "$initial_task" ]]; then
  task_dir="$target/work-artifacts/$created_date-$initial_task"
  mkdir_dir "$task_dir"

  write_file "$task_dir/README.md" <<EOF
# $task_title

Created: $created_date
Updated: $created_date
Version: 0.1
Status: active
Type: $task_kind

## Purpose

Describe why this $task_kind exists and what decision or outcome it should support.

## Scope

In scope:

- Define the durable work for this $task_kind.

Out of scope:

- Add items here when boundaries become clear.

## Current Outputs

- Tracker: \`tracker.md\`
- Journal: \`journal.md\`

## Decisions

- This folder is the durable record for this $task_kind.

## Open Questions

- What should be decided or verified next?

## Next Step

Update \`tracker.md\` with the current question, constraints and next action.

## Change Log

- $created_date v0.1: created $task_kind folder.
EOF

  write_file "$task_dir/tracker.md" <<EOF
# Tracker

Created: $created_date
Updated: $created_date
Version: 0.1

## Current Question

What is the current question for this $task_kind?

## Current Decisions

- This folder is the canonical durable record for this $task_kind.

## What Contradicts The Current Model

- Add risks, counterevidence or uncertainty here.

## Open Questions

- What still needs a decision?

## Next Steps

1. Add the next concrete action.

## Change Log

- $created_date v0.1: started tracker.
EOF

  write_file "$task_dir/journal.md" <<EOF
# Journal

Created: $created_date
Updated: $created_date
Version: 0.1

## $created_date

### Entry 1

Timestamp: $timestamp
Agent: not recorded
Session ID: not recorded

Question at this moment:

- Start a durable $task_kind folder.

Attempt:

- Created the minimal README, tracker and journal scaffold.

Evidence:

- The scaffold exists in this folder.

Result:

- The $task_kind folder is ready for work.

Interpretation:

- Future updates should preserve the path of thought, not only final outputs.

## Change Log

- $created_date v0.1: started journal.
EOF

  if [[ "$with_source_dirs" -eq 1 ]]; then
    mkdir_dir "$task_dir/sources"
    mkdir_dir "$task_dir/file-summaries"
  fi
fi

if [[ "$git_init" -eq 1 ]]; then
  if [[ -d "$target/.git" ]]; then
    note "Exists: $target/.git"
  else
    run git -C "$target" init
  fi
fi

note "HARE Trail data scaffold ready: $target"
