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
ui_lang="${HARETRAIL_UI_LANG:-}"   # language for skill trigger phrases / how the user addresses the agent
gen_triggers=""                     # if set to a lang code, (re)generate trigger phrases for it and exit
assume_yes=0                        # non-interactive: never prompt

skills=(
  task
  summary
  research
  doc-write
  debrief
  lessons
  postmortem
  contribution-log
  work-evidence
  daily
  retro
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
  --ui-lang CODE        Language for skill trigger phrases (how you address the agent), e.g. en, ru, es.
                        Default chain: --ui-lang -> HARETRAIL_UI_LANG -> HARETRAIL_ARTIFACT_LANG -> $LANG -> en.
                        English triggers always work as a fallback regardless of this choice.
  --gen-triggers CODE   (Re)generate trigger phrases for CODE via a local AI CLI, write them to
                        <config-dir>/triggers/CODE.json, then exit. Use to add/refresh a language later.
  --yes, -y             Non-interactive: never prompt; use computed defaults.
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
    --ui-lang)
      ui_lang="${2:-}"
      shift 2
      ;;
    --gen-triggers)
      gen_triggers="${2:-}"
      shift 2
      ;;
    --yes|-y)
      assume_yes=1
      shift
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

# Preserved backups live OUTSIDE any scanned skill root so host tools (Codex /
# Claude skill discovery) never index a stale ".bak" copy as a live skill.
backup_root="$config_dir/connector-backups/$timestamp"

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

# --- Language / trigger phrase helpers ----------------------------------------
# Triggers are short words/phrases a user says to invoke a skill; the host agent
# matches the user's request against them. They are language-dependent (a Russian
# user's "сделай дебриф" needs Russian triggers), whereas skill DESCRIPTIONS are
# canonical English (the model understands a request in any language from them).
# English triggers are always merged in as a fallback. Per-language phrase files
# live OUTSIDE the repo in <config-dir>/triggers/<lang>.json; only the English
# baseline (scripts/triggers/en.json) ships versioned with the system repo.

triggers_repo_baseline="$repo_root/scripts/triggers/en.json"

# Read a single KEY=value from an existing config.env (used for the smart default
# chain: HARETRAIL_UI_LANG falls back to HARETRAIL_ARTIFACT_LANG). Prints nothing
# if the file or key is absent.
read_config_value() {
  local key="$1"
  [[ -f "$config_file" ]] || return 0
  # Last assignment wins; strip optional surrounding quotes.
  local line
  line="$(grep -E "^${key}=" "$config_file" 2>/dev/null | tail -n 1)"
  [[ -n "$line" ]] || return 0
  local val="${line#*=}"
  val="${val%\"}"
  val="${val#\"}"
  printf '%s' "$val"
}

# Normalise a locale-ish string to a bare 2-letter language code (ru_RU.UTF-8 -> ru).
normalize_lang() {
  local raw="$1"
  raw="${raw%%.*}"   # drop .UTF-8 etc.
  raw="${raw%%_*}"   # drop _RU etc.
  raw="${raw%%@*}"   # drop @euro etc.
  printf '%s' "$raw" | tr '[:upper:]' '[:lower:]'
}

# Resolve the UI/trigger language via the documented default chain:
#   --ui-lang flag  ->  HARETRAIL_UI_LANG (env or config)  ->
#   HARETRAIL_ARTIFACT_LANG (config)  ->  $LANG/$LC_ALL  ->  en
# Interactive sessions get to confirm/override the computed default.
resolve_ui_lang() {
  local computed=""
  if [[ -n "$ui_lang" ]]; then
    computed="$ui_lang"                                  # flag or HARETRAIL_UI_LANG env
  fi
  if [[ -z "$computed" ]]; then
    computed="$(read_config_value HARETRAIL_UI_LANG)"
  fi
  if [[ -z "$computed" ]]; then
    computed="$(read_config_value HARETRAIL_ARTIFACT_LANG)"
  fi
  if [[ -z "$computed" ]]; then
    computed="$(normalize_lang "${LC_ALL:-${LANG:-}}")"
  fi
  [[ -n "$computed" ]] || computed="en"
  computed="$(normalize_lang "$computed")"

  # Ask interactively unless suppressed or already pinned via flag/env.
  if [[ "$assume_yes" -eq 0 && -t 0 && -z "$ui_lang" ]]; then
    local answer
    printf 'UI/trigger language for skill wrappers (e.g. en, ru, es) [%s]: ' "$computed" >&2
    if read -r answer && [[ -n "$answer" ]]; then
      computed="$(normalize_lang "$answer")"
    fi
  fi

  ui_lang="$computed"
}

# Locate a phrase file for a language: prefer a generated/edited file under the
# config dir, then the repo baseline for English. Prints the path or nothing.
triggers_file_for() {
  local lang="$1"
  if [[ -f "$config_dir/triggers/$lang.json" ]]; then
    printf '%s' "$config_dir/triggers/$lang.json"
  elif [[ "$lang" == "en" && -f "$triggers_repo_baseline" ]]; then
    printf '%s' "$triggers_repo_baseline"
  fi
}

# Extract the phrase list for one skill from one JSON file, as a comma+space
# joined string. Uses python3 (widely available) and degrades to empty on any
# error so the caller can fall back to the English baseline / skill name.
triggers_from_file() {
  local file="$1" skill="$2"
  [[ -n "$file" && -f "$file" ]] || return 0
  command -v python3 >/dev/null 2>&1 || return 0
  python3 - "$file" "$skill" <<'PY' 2>/dev/null || true
import json, sys
try:
    with open(sys.argv[1], encoding="utf-8") as fh:
        data = json.load(fh)
    phrases = data.get(sys.argv[2], [])
    phrases = [str(p).strip() for p in phrases if str(p).strip()]
    sys.stdout.write(", ".join(phrases))
except Exception:
    pass
PY
}

# Build the comma-joined trigger phrase string for one skill: configured language
# first, English baseline always appended as fallback, de-duplicated, never empty
# (falls back to the skill name).
triggers_for_skill() {
  local skill="$1"
  local lang_file en_file lang_phrases en_phrases combined

  lang_file="$(triggers_file_for "$ui_lang")"
  en_file="$(triggers_file_for en)"

  lang_phrases=""
  if [[ "$ui_lang" != "en" ]]; then
    lang_phrases="$(triggers_from_file "$lang_file" "$skill")"
  fi
  en_phrases="$(triggers_from_file "$en_file" "$skill")"

  # Merge: configured language phrases first, then English fallback. De-dup while
  # preserving order; if nothing resolved, fall back to the skill name itself.
  combined="$lang_phrases"
  if [[ -n "$combined" && -n "$en_phrases" ]]; then
    combined="$combined, $en_phrases"
  elif [[ -z "$combined" ]]; then
    combined="$en_phrases"
  fi
  [[ -n "$combined" ]] || combined="$skill"

  printf '%s' "$combined" | awk -v RS=', *' 'NF && !seen[$0]++ { printf "%s%s", (n++?", ":""), $0 }'
}

# Generate trigger phrases for a non-English language via a local AI CLI (claude
# or codex), seeding from the English baseline + skill descriptions. Writes
# <config-dir>/triggers/<lang>.json. Returns non-zero (without failing the whole
# install) if no CLI is available or generation produced no usable file.
generate_triggers() {
  local lang="$1"
  local out_dir="$config_dir/triggers"
  local out_file="$out_dir/$lang.json"

  if [[ "$lang" == "en" ]]; then
    note "English triggers ship as the versioned baseline; nothing to generate."
    return 0
  fi

  local cli=""
  if command -v claude >/dev/null 2>&1; then
    cli="claude"
  elif command -v codex >/dev/null 2>&1; then
    cli="codex"
  fi

  if [[ -z "$cli" ]]; then
    note "No local AI CLI (claude/codex) found to generate '$lang' triggers."
    note "Copy the English baseline and translate the phrases by hand:"
    note "  mkdir -p $out_dir && cp $triggers_repo_baseline $out_file"
    note "  # then edit $out_file (keep the JSON keys, translate the phrase lists)"
    return 1
  fi

  run mkdir -p "$out_dir"

  # Build the descriptions block so the model adapts phrasing, not blind translation.
  local descs="" skill
  for skill in "${skills[@]}"; do
    descs+="- $skill: $(skill_description "$skill")"$'\n'
  done

  local baseline_json="{}"
  [[ -f "$triggers_repo_baseline" ]] && baseline_json="$(cat "$triggers_repo_baseline")"

  local prompt
  prompt="You localize skill trigger phrases for the HARE Trail CLI into language code '$lang'.
Trigger phrases are short words/phrases a user would say to invoke a skill; the agent matches the user's request against them. Adapt them naturally for native speakers of '$lang' (idiomatic invocations, NOT literal word-for-word translation). Keep obvious English technical tokens (e.g. README, LESSONS.md, self-review, postmortem) if a native speaker would actually use them.

Skill descriptions (canonical English, for context only):
$descs
English baseline phrases (JSON; same keys you must output):
$baseline_json

Output ONLY a JSON object mapping each skill key above to an array of 4-6 trigger phrases in '$lang'. No prose, no markdown fences, no _comment key. Keys must exactly match: ${skills[*]}."

  if [[ "$dry_run" -eq 1 ]]; then
    note "[dry-run] would generate $out_file via $cli for language '$lang'"
    return 0
  fi

  note "Generating '$lang' trigger phrases via $cli (this calls your local AI CLI)..."
  # Run from a neutral directory and strip project context so the CLI does not
  # load this project's skills/CLAUDE.md or leak cwd/git/memory into the answer
  # (that pollutes the output and can even make the model refuse). A strict
  # JSON-formatter system prompt keeps the response parseable.
  local sys_prompt='You are a strict JSON formatter. Output only the exact JSON object the user asks for. Never add prose, explanations, markdown fences, or commentary. Do not use tools.'
  local generated=""
  if [[ "$cli" == "claude" ]]; then
    generated="$(cd / && printf '%s' "$prompt" | claude -p \
      --system-prompt "$sys_prompt" \
      --exclude-dynamic-system-prompt-sections \
      --setting-sources '' 2>/dev/null || true)"
  else
    generated="$(cd / && printf '%s' "$prompt" | codex exec - 2>/dev/null || true)"
  fi

  # Validate and normalise via python. The raw model text goes through a temp
  # FILE (passed as argv), not stdin, because stdin is already taken by the
  # heredoc script ('python3 -' reads the program from stdin). The parser trims
  # to the outermost JSON object, so stray prose or markdown fences are tolerated.
  local raw_file
  raw_file="$(mktemp "${TMPDIR:-/tmp}/haretrail-triggers.XXXXXX")" || return 1
  printf '%s' "$generated" > "$raw_file"
  if python3 - "$raw_file" "$out_file" "${skills[@]}" <<'PY'
import json, sys
raw_path, out_path = sys.argv[1], sys.argv[2]
want = sys.argv[3:]
with open(raw_path, encoding="utf-8") as fh:
    raw = fh.read().strip()
# Trim to the outermost JSON object if the model added stray text/fences.
start, end = raw.find("{"), raw.rfind("}")
if start == -1 or end == -1:
    sys.exit(1)
try:
    data = json.loads(raw[start:end + 1])
except Exception:
    sys.exit(1)
clean = {}
for k in want:
    vals = data.get(k, [])
    if isinstance(vals, str):
        vals = [vals]
    vals = [str(v).strip() for v in vals if str(v).strip()]
    if vals:
        clean[k] = vals
if not clean:
    sys.exit(1)
clean = {"_comment": "HARE Trail trigger phrases (generated; edit by hand to refine). English is always merged as a fallback.", **clean}
with open(out_path, "w", encoding="utf-8") as fh:
    json.dump(clean, fh, ensure_ascii=False, indent=2)
    fh.write("\n")
PY
  then
    rm -f "$raw_file"
    note "Wrote generated triggers: $out_file"
    note "Review and tweak the phrases there; English always stays as a fallback."
    return 0
  else
    rm -f "$raw_file"
    note "Generation did not return usable JSON. Falling back to English-only triggers for '$lang'."
    note "You can retry later: install-connectors.sh --gen-triggers $lang   (or edit $out_file by hand)."
    return 1
  fi
}
# --- end language / trigger helpers -------------------------------------------

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

# Move a path into the external backup root, preserving it but taking it out of
# any scanned skill directory. The absolute path is mirrored under backup_root
# to avoid collisions (e.g. codex vs claude both have "research") and to keep
# restores obvious.
stash_backup() {
  local path="$1"
  local dest="$backup_root$path"

  if [[ "$dry_run" -eq 1 ]]; then
    printf '[dry-run] mv %q %q\n' "$path" "$dest"
    note "Would back up $path -> $dest"
    return
  fi

  mkdir -p "$(dirname -- "$dest")"
  mv "$path" "$dest"
  note "Backed up $path -> $dest"
}

# Sweep stale "<name>.bak.<ts>" siblings left in a skill dir by older versions
# of this script into the external backup root, so they stop showing up as
# duplicate skills. Backups are kept, just relocated.
relocate_legacy_backups() {
  local dir="$1"
  [[ -d "$dir" ]] || return 0

  local b
  for b in "$dir"/*.bak.*; do
    [[ -e "$b" ]] || continue
    stash_backup "$b"
  done
}

backup_if_needed() {
  local path="$1"

  if [[ -e "$path" && ! -L "$path" ]]; then
    stash_backup "$path"
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
    stash_backup "$target"
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
    work-evidence)
      printf 'Work Evidence'
      ;;
    daily)
      printf 'Daily'
      ;;
    retro)
      printf 'Retro'
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
      printf 'Create, find and update task-folders in the HARE Trail data repo work-artifacts. Maintain tracker and journal, import materials.'
      ;;
    summary)
      printf 'Process a batch of documents or files for HARE Trail: copy sources, convert formats, write summaries and file summaries, extract quotes, build mermaid diagrams.'
      ;;
    research)
      printf 'Run a research task in HARE Trail: research plan, sources, hypotheses, verification, prompts for external AIs.'
      ;;
    doc-write)
      printf 'Write and update human-readable documentation in HARE Trail: README files, descriptions of systems, processes and decisions.'
      ;;
    debrief)
      printf 'Read, create and update session debriefs and LESSONS.md in HARE Trail. Record mistakes, lessons and corrections from working sessions.'
      ;;
    lessons)
      printf 'Read and update LESSONS.md in HARE Trail: add a lesson, refine wording, or show lessons without a full debrief.'
      ;;
    postmortem)
      printf 'Create heavy incident-grade postmortems in HARE Trail: Timeline, Impact, 5 Whys, Winback Plan, Lessons Learned.'
      ;;
    contribution-log)
      printf 'Maintain contribution/self-review logs in HARE Trail: record contributions, invisible work, help given to others, and prepare material for self-review.'
      ;;
    work-evidence)
      printf 'Движок сбора evidence о работе за период из трекера/чата/code-host/заметок в нормализованный source-bound ledger для daily и contribution-log.'
      ;;
    daily)
      printf 'Собрать рабочий daily-стендап за период поверх work-evidence: 4 секции (прогресс, invisible work, инсайты/вопросы, блокеры), атрибуция КТО ЧТО.'
      ;;
    retro)
      printf 'Собрать рабочую ретроспективу за период (дейлики + ЛС + список чатов): что зашло, что расстроило, что решилось vs открыто, открытые вопросы, кого поблагодарить, боли команды.'
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
      stash_backup "$agent_file"
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
  local prompt="You are the HARE Trail working agent. HARE Trail is a file-first work and research system that preserves the whole path of work (sources, questions, attempts, evidence, debriefs and lessons), not only final outputs. Reusable system repo: $repo_root. Private data repo: $data_dir. Resolve any {data-repo} placeholder to $data_dir. Before acting, read your loaded resources: the reusable behavior contract system-behavior.md, the SKILL for the requested workflow (task, summary, research, doc-write, debrief, lessons, postmortem, contribution-log), and the data repo AGENTS.md and BASE.md. Follow progressive disclosure: read README and tracker before long journals and raw sources. Keep private artifacts in the data repo and never copy them into the system repo. When editing files inside an external project repo, follow that project rules and language. Write working artifacts in the language configured as HARETRAIL_ARTIFACT_LANG in the local config (~/.haretrail/config.env); if unset, fall back to the language of the current user/dialogue. Do not hardcode a specific language."

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
      stash_backup "$steering_file"
    fi
  fi

  # Build the skill dispatch table for the steering file.
  # Triggers come from the configured UI language (English always merged as a
  # fallback) so a native-language request reliably dispatches to the right skill.
  local skill_table="" st_skill st_triggers
  for st_skill in "${skills[@]}"; do
    st_triggers="$(triggers_for_skill "$st_skill")"
    skill_table+="| $st_triggers | $repo_root/skills/$st_skill/SKILL.md |"$'\n'
  done
  skill_table="${skill_table%$'\n'}"

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
- Write working artifacts in the language configured as \`HARETRAIL_ARTIFACT_LANG\` in the local config (\`~/.haretrail/config.env\`); if unset, fall back to the language of the current user/dialogue. Do not hardcode a specific language.

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
        stash_backup "$skill_md"
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

Before acting, read the canonical workflow:
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
      stash_backup "$workspace_file"
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
    stash_backup "$config_file"
  fi

  write_file "$config_file" "# HARE Trail local config
# Generated by scripts/install-connectors.sh

HARETRAIL_SYSTEM_DIR=$repo_root
HARETRAIL_DATA_DIR=$data_dir
# Language for skill trigger phrases / how you address the agent. English always
# works as a fallback. Per-language phrases live in $config_dir/triggers/<lang>.json.
HARETRAIL_UI_LANG=$ui_lang

# Optional settings for the daily / retro / work-evidence skills.
# Fill in on first run (the skill asks and saves them here). Do not hardcode defaults.
# HARETRAIL_TRACKER=          # task tracker, e.g. jira (+ access: mcp/cli/api)
# HARETRAIL_CHAT=             # team chat, e.g. slack (+ access)
# HARETRAIL_CODEHOST=         # code host, e.g. github (+ login/org)
# HARETRAIL_PULL_STRATEGY=    # all | partial
# HARETRAIL_WORK_FILTER=      # work vs personal: org, ticket prefixes, personal paths/repos
# HARETRAIL_DAILY_CADENCE=    # e.g. mon,thu
# HARETRAIL_RETRO_CADENCE=    # e.g. 2w (retro)
# HARETRAIL_RETRO_CHATS=      # chats to scan for problems (retro)
# HARETRAIL_LANG=             # output language
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

# --gen-triggers <lang>: (re)generate phrases for one language and exit. Standalone
# operation — does not install or modify connectors.
if [[ -n "$gen_triggers" ]]; then
  gen_lang="$(normalize_lang "$gen_triggers")"
  generate_triggers "$gen_lang"
  exit $?
fi

validate_data_dir

# Resolve the UI/trigger language once (flag -> env -> config -> $LANG -> en, with
# an interactive confirm). Auto-generate phrases for a non-English language the
# first time we see it, so wrapper triggers match how the user actually speaks.
resolve_ui_lang
note "UI/trigger language: $ui_lang (English always works as a fallback)"
if [[ "$ui_lang" != "en" && -z "$(triggers_file_for "$ui_lang")" ]]; then
  if [[ "$assume_yes" -eq 1 ]]; then
    note "No '$ui_lang' trigger phrases yet; using English-only triggers (run --gen-triggers $ui_lang to add them)."
  else
    generate_triggers "$ui_lang" || true
  fi
fi

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
relocate_legacy_backups "$codex_home/skills"

for skill in "${skills[@]}"; do
  if [[ "$install_mode" == "wrapper" ]]; then
    install_wrapper "$skill" "$codex_home/skills/$skill"
  else
    link_path "$repo_root/skills/$skill" "$codex_home/skills/$skill"
  fi
done

if [[ "$include_agents" -eq 1 ]]; then
  run mkdir -p "$agents_home/skills"
  relocate_legacy_backups "$agents_home/skills"
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
  relocate_legacy_backups "$claude_home/skills"
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
