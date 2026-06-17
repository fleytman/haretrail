#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
timestamp="$(date +%Y%m%d%H%M%S)"

codex_home="${CODEX_HOME:-$HOME/.codex}"
agents_home="${AGENTS_HOME:-$HOME/.agents}"
claude_home="${CLAUDE_HOME:-$HOME/.claude}"
kiro_home="${KIRO_HOME:-$HOME/.kiro}"
data_dir="${HARETRAIL_DATA_DIR:-}"
config_dir="${HARETRAIL_CONFIG_DIR:-$HOME/.haretrail}"
config_file=""

dry_run=0
include_claude=0
include_agents=0
include_kiro_cli=0
include_kiro_ide=0
open_workspace=0
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
  --include-kiro-cli    Generate a HARE Trail agent config for Kiro CLI under ~/.kiro/agents. Requires --data-dir.
  --include-kiro        Alias for --include-kiro-cli (backward compatibility).
  --include-kiro-ide    Generate HARE Trail steering + skill wrappers for Kiro IDE under ~/.kiro/steering and ~/.kiro/skills, plus a multi-root .code-workspace under the config dir so the IDE agent can reach the data repo. Requires --data-dir.
  --open-workspace      After --include-kiro-ide, open the generated multi-root .code-workspace in Kiro IDE via the 'kiro' CLI (if found on PATH). Makes setup fully hands-off.
  --mode MODE           Connector mode: source or wrapper. Default: source.
  --write-config        Write local config.env under ~/.haretrail or --config-dir.
  --data-dir PATH       Data repo root. Overrides HARETRAIL_DATA_DIR for validation output.
  --config-dir PATH     Local config directory. Default: $HARETRAIL_CONFIG_DIR or ~/.haretrail.
  --codex-home PATH     Codex home directory. Default: $CODEX_HOME or ~/.codex.
  --agents-home PATH    Agents home directory. Default: $AGENTS_HOME or ~/.agents.
  --claude-home PATH    Claude home directory. Default: $CLAUDE_HOME or ~/.claude.
  --kiro-home PATH      Kiro home directory. Default: $KIRO_HOME or ~/.kiro.
  -h, --help            Show this help.

Notes:
  - This script installs symlinks to reusable source skill folders.
  - Wrapper mode installs small local SKILL.md files that point to canonical source skills.
  - Kiro CLI support generates ~/.kiro/agents/haretrail.json referencing canonical source skills via skill:// and the data repo via file://.
  - Kiro IDE support generates ~/.kiro/steering/haretrail.md and ~/.kiro/skills/haretrail-<skill>.md wrappers that reference canonical skill sources, plus a multi-root .code-workspace so the IDE agent can access the data repo.
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
    --include-kiro)
      include_kiro_cli=1
      shift
      ;;
    --include-kiro-cli)
      include_kiro_cli=1
      shift
      ;;
    --include-kiro-ide)
      include_kiro_ide=1
      shift
      ;;
    --open-workspace)
      open_workspace=1
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
    --kiro-home)
      kiro_home="${2:-}"
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

skill_description() {
  local skill="$1"

  case "$skill" in
    task)
      printf 'Создавать, находить и обновлять task-folders в HARE Trail data repo work-artifacts. Вести tracker и journal, импортировать материалы.'
      ;;
    summary)
      printf 'Обрабатывать пакет документов или файлов для HARE Trail: копировать источники, конвертировать форматы, делать summary, file summaries, извлекать цитаты, строить mermaid-схемы.'
      ;;
    research)
      printf 'Вести исследовательскую задачу в HARE Trail: план исследования, sources, гипотезы, verification, prompts для внешних ИИ.'
      ;;
    doc-write)
      printf 'Писать и обновлять human-readable документацию в HARE Trail: README, описания систем, процессов и решений.'
      ;;
    debrief)
      printf 'Читать, создавать и обновлять session debriefs и LESSONS.md в HARE Trail. Записывать ошибки, уроки, коррекции из рабочих сессий.'
      ;;
    lessons)
      printf 'Читать и обновлять LESSONS.md в HARE Trail: добавить урок, уточнить формулировку, показать уроки без полного debrief.'
      ;;
    postmortem)
      printf 'Создавать тяжёлые incident-grade postmortems в HARE Trail: Timeline, Impact, 5 Whys, Winback Plan, Lessons Learned.'
      ;;
    contribution-log)
      printf 'Вести contribution/self-review logs в HARE Trail: записывать вклад, invisible work, помощь другим, готовить материал для self-review.'
      ;;
    *)
      printf 'HARE Trail %s skill.' "$skill"
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

install_kiro_agent() {
  local agents_dir="$kiro_home/agents"
  local agent_file="$agents_dir/haretrail.json"

  run mkdir -p "$agents_dir"

  # Back up a foreign agent file so we never silently overwrite a user's own config.
  # Our generated files are self-identified by a marker string in the description.
  if [[ "$dry_run" -eq 0 && -e "$agent_file" ]]; then
    if ! grep -q 'generated-by=haretrail-install-connectors' "$agent_file" 2>/dev/null; then
      local backup_path="${agent_file}.bak.${timestamp}"
      mv "$agent_file" "$backup_path"
      note "Backed up $agent_file -> $backup_path"
    fi
  fi

  # Build the resources array: skills load on demand (skill://), shared behavior
  # and data-repo rules are always in context (file://). LESSONS.md is intentionally
  # not force-loaded; it is read on demand through the lessons skill.
  local res_json="" first=1 skill
  for skill in "${skills[@]}"; do
    if [[ "$first" -eq 1 ]]; then first=0; else res_json+=$',\n'; fi
    res_json+="    \"skill://$repo_root/skills/$skill/SKILL.md\""
  done
  res_json+=$',\n'"    \"file://$repo_root/skills/_shared/system-behavior.md\""
  if [[ -f "$data_dir/AGENTS.md" ]]; then
    res_json+=$',\n'"    \"file://$data_dir/AGENTS.md\""
  fi
  if [[ -f "$data_dir/BASE.md" ]]; then
    res_json+=$',\n'"    \"file://$data_dir/BASE.md\""
  fi

  # Single-line prompt: no double quotes or backslashes so it is safe inside JSON.
  local prompt="You are the HARE Trail working agent. HARE Trail is a file-first work and research system that preserves the whole path of work (sources, questions, attempts, evidence, debriefs and lessons), not only final outputs. Reusable system repo: $repo_root. Private data repo: $data_dir. Resolve any {data-repo} placeholder to $data_dir. Before acting, read your loaded resources: the reusable behavior contract system-behavior.md, the SKILL for the requested workflow (task, summary, research, doc-write, debrief, lessons, postmortem, contribution-log), and the data repo AGENTS.md and BASE.md. Follow progressive disclosure: read README and tracker before long journals and raw sources. Keep private artifacts in the data repo and never copy them into the system repo. When editing files inside an external project repo, follow that project rules and language. Default working language for this user artifacts is Russian unless a target project requires otherwise."

  local content
  content="$(cat <<JSON
{
  "name": "haretrail",
  "description": "HARE Trail working agent (generated-by=haretrail-install-connectors). System repo: $repo_root. Data repo: $data_dir.",
  "prompt": "$prompt",
  "tools": ["read", "write", "shell", "grep", "glob", "code"],
  "allowedTools": ["read", "grep", "glob"],
  "resources": [
$res_json
  ]
}
JSON
)"

  write_file "$agent_file" "$content"
  note "Generated Kiro agent $agent_file"
  note "Run it with: kiro-cli chat --agent haretrail"
}

install_kiro_ide() {
  local steering_dir="$kiro_home/steering"
  local skills_dir="$kiro_home/skills"
  local steering_file="$steering_dir/haretrail.md"

  run mkdir -p "$steering_dir"
  run mkdir -p "$skills_dir"

  # Back up foreign steering file if it exists and is not ours.
  if [[ "$dry_run" -eq 0 && -e "$steering_file" ]]; then
    if ! grep -q 'generated-by=haretrail-install-connectors' "$steering_file" 2>/dev/null; then
      local backup_path="${steering_file}.bak.${timestamp}"
      mv "$steering_file" "$backup_path"
      note "Backed up $steering_file -> $backup_path"
    fi
  fi

  # Build the skill dispatch table for the steering file.
  local skill_table=""
  skill_table+="| задача, task-folder, work-artifacts | $repo_root/skills/task/SKILL.md |"$'\n'
  skill_table+="| summary, пакет документов, sources | $repo_root/skills/summary/SKILL.md |"$'\n'
  skill_table+="| исследование, research, гипотезы | $repo_root/skills/research/SKILL.md |"$'\n'
  skill_table+="| документ, doc-write, написать доку | $repo_root/skills/doc-write/SKILL.md |"$'\n'
  skill_table+="| дебриф, debrief, ошибки сессии | $repo_root/skills/debrief/SKILL.md |"$'\n'
  skill_table+="| уроки, lessons, LESSONS.md | $repo_root/skills/lessons/SKILL.md |"$'\n'
  skill_table+="| постмортем, postmortem, инцидент | $repo_root/skills/postmortem/SKILL.md |"$'\n'
  skill_table+="| вклад, contribution, self-review | $repo_root/skills/contribution-log/SKILL.md |"

  # Optional data repo rules references.
  local data_rules=""
  if [[ -f "$data_dir/AGENTS.md" ]]; then
    data_rules+="Also read the data repo rules: \`$data_dir/AGENTS.md\`"
    if [[ -f "$data_dir/BASE.md" ]]; then
      data_rules+=" and \`$data_dir/BASE.md\`"
    fi
    data_rules+="."
  fi

  # Generate steering file: always-loaded context with paths, core behavior, and skill dispatch.
  local steering_content
  steering_content="---
inclusion: auto
name: haretrail
description: \"HARE Trail: file-first work/research system. Paths, rules, and skill dispatch for all HARE Trail workflows.\"
---
<!-- generated-by=haretrail-install-connectors -->
# HARE Trail

File-first work and research system. Preserves the whole path of work, not only final outputs.

## Paths

- System repo: $repo_root
- Data repo: $data_dir
- Shared behavior: $repo_root/skills/_shared/system-behavior.md

Resolve any \`{data-repo}\` placeholder to \`$data_dir\`.

## Core Rules

- Read the shared behavior contract (\`$repo_root/skills/_shared/system-behavior.md\`) before acting on HARE Trail workflows.
- Follow progressive disclosure: README/tracker first, then summaries/verification, then long journals/raw sources.
- Keep private artifacts in the data repo. Never copy them into the system repo.
- When editing files in an external project repo, follow that project's rules and language.
- Default working language for user artifacts: Russian (unless a target project requires otherwise).

## Skill Dispatch

When the user asks for a HARE Trail workflow, read the corresponding SKILL.md and its references/workflow.md before acting:

| Trigger | Skill path |
|---------|-----------|
$skill_table

$data_rules"

  write_file "$steering_file" "$steering_content"
  note "Generated Kiro IDE steering: $steering_file"

  # Generate skill folders: each skill is a directory with SKILL.md inside.
  # Kiro IDE expects ~/.kiro/skills/<name>/SKILL.md (not flat files).
  local skill skill_dir skill_md title desc
  for skill in "${skills[@]}"; do
    skill_dir="$skills_dir/haretrail-${skill}"
    skill_md="$skill_dir/SKILL.md"

    run mkdir -p "$skill_dir"

    # Back up foreign SKILL.md if needed.
    if [[ "$dry_run" -eq 0 && -e "$skill_md" ]]; then
      if ! grep -q 'generated-by=haretrail-install-connectors' "$skill_md" 2>/dev/null; then
        local backup_path="${skill_md}.bak.${timestamp}"
        mv "$skill_md" "$backup_path"
        note "Backed up $skill_md -> $backup_path"
      fi
    fi

    title="$(skill_title "$skill")"
    desc="$(skill_description "$skill")"

    write_file "$skill_md" "---
name: haretrail-${skill}
description: \"${desc}\"
---
<!-- generated-by=haretrail-install-connectors -->
# $title (HARE Trail)

Перед работой прочитай каноничный workflow:
- \`$repo_root/skills/$skill/SKILL.md\`
- \`$repo_root/skills/$skill/references/workflow.md\`
- \`$repo_root/skills/_shared/system-behavior.md\`

Resolve \`{data-repo}\` to \`$data_dir\`.

System repo: \`$repo_root\`
Data repo: \`$data_dir\`
Data repo rules: \`$data_dir/AGENTS.md\`, \`$data_dir/BASE.md\`
"
    note "Generated Kiro IDE skill: $skill_md"
  done

  # Generate a multi-root workspace so the Kiro IDE agent can access both the
  # system repo and the private data repo in one session. Without this, the IDE
  # sandbox restricts file access to a single opened folder, and the data repo
  # (which lives outside the system repo by design) is unreachable. The file is
  # written under the local config dir, never inside the system or data repo.
  local workspace_file="$config_dir/haretrail.code-workspace"

  run mkdir -p "$config_dir"

  if [[ "$dry_run" -eq 0 && -e "$workspace_file" ]]; then
    if ! grep -q 'generated-by=haretrail-install-connectors' "$workspace_file" 2>/dev/null; then
      local backup_path="${workspace_file}.bak.${timestamp}"
      mv "$workspace_file" "$backup_path"
      note "Backed up $workspace_file -> $backup_path"
    fi
  fi

  write_file "$workspace_file" "{
  \"folders\": [
    { \"name\": \"haretrail-data\", \"path\": \"$data_dir\" },
    { \"name\": \"haretrail (system)\", \"path\": \"$repo_root\" }
  ],
  \"settings\": {
    \"//\": \"generated-by=haretrail-install-connectors\"
  }
}"
  note "Generated Kiro IDE workspace: $workspace_file"

  # Optionally open the workspace so the agent can reach both repos with no
  # manual step. The IDE sandbox cannot reach an external folder until a
  # workspace containing it is opened, so this is the only way to make setup
  # fully hands-off. Opt-in via --open-workspace; we never launch the IDE silently.
  if [[ "$open_workspace" -eq 1 ]]; then
    if command -v kiro >/dev/null 2>&1; then
      run kiro "$workspace_file"
      note "Opened workspace in Kiro IDE: $workspace_file"
    else
      note "Could not find the 'kiro' CLI on PATH; open the workspace manually:"
      note "  File > Open Workspace from File... -> $workspace_file"
    fi
  else
    note "Open this workspace in Kiro IDE so the agent can reach both repos:"
    note "  File > Open Workspace from File... -> $workspace_file"
    note "  (or re-run with --open-workspace to open it automatically)"
  fi
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

if [[ "$include_kiro_cli" -eq 1 && -z "$data_dir" ]]; then
  printf 'The --include-kiro-cli option requires --data-dir or HARETRAIL_DATA_DIR.\n' >&2
  exit 2
fi

if [[ "$include_kiro_ide" -eq 1 && -z "$data_dir" ]]; then
  printf 'The --include-kiro-ide option requires --data-dir or HARETRAIL_DATA_DIR.\n' >&2
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

if [[ "$include_kiro_cli" -eq 1 ]]; then
  install_kiro_agent
  note "Kiro CLI agent connector installed."
else
  note "Skipped Kiro CLI connector. Use --include-kiro-cli to generate the ~/.kiro agent config."
fi

if [[ "$include_kiro_ide" -eq 1 ]]; then
  install_kiro_ide
  note "Kiro IDE connectors installed."
else
  note "Skipped Kiro IDE connector. Use --include-kiro-ide to generate steering and skill wrappers."
fi

note "Installed HARE Trail connectors from $repo_root in $install_mode mode."
note "Data repo resolution remains runtime-configured via HARETRAIL_DATA_DIR, current workspace, or host-tool config."
