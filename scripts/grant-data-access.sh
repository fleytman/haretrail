#!/usr/bin/env bash
#
# grant-data-access.sh — raise host-agent (Claude Code, Codex CLI, Kiro CLI)
# permissions for the HARE Trail data repo to parity with a trusted current
# working directory, so routine file/folder/git operations in the data repo do
# not prompt every time.
#
# Principles (see file-summaries/2026-06-10-agent-permissions-deep-research-summary.md):
#   - Parity with cwd, not stricter: the data repo becomes a trusted writable
#     root at the same trust level as a normal working repo.
#   - Data safety comes from per-task local git repos + frequent commits, not
#     from an aggressive deny-list.
#   - Symlinking an artifact into a working repo is a feature: ln is NOT denied.
#   - Scoped to the data repo path. Idempotent. Backs up every file it edits.
#   - Never writes into the data repo; never enables global full-access blindly.
#
# Usage:
#   grant-data-access.sh [--apply] [--yes] [--data-dir PATH] [--all]
#                        [--include-claude] [--include-codex] [--include-kiro]
#                        [--kiro-agent NAME] [--kiro-mode scoped|broad]
#                        [--claude-home P] [--codex-home P] [--kiro-home P]
#                        [--config-dir P]
#
# Default is a DRY RUN (prints planned changes). Pass --apply to write.
# On --apply the script first shows the exact permissions it will grant and asks
# for confirmation (first-time informed consent). Pass --yes to skip the prompt
# in automation / non-interactive shells.
# If no --include-* flag is given, all detected tools are targeted.

set -euo pipefail

ts="$(date +%Y%m%d%H%M%S)"
config_dir="${HARETRAIL_CONFIG_DIR:-$HOME/.haretrail}"
apply=0
assume_yes=0
sel_claude=0 sel_codex=0 sel_kiro=0 any_sel=0
kiro_agent="haretrail"
kiro_mode="scoped"
data_dir="${HARETRAIL_DATA_DIR:-}"
claude_home="${CLAUDE_HOME:-$HOME/.claude}"
codex_home="${CODEX_HOME:-$HOME/.codex}"
kiro_home="${KIRO_HOME:-$HOME/.kiro}"

usage() { sed -n '2,40p' "$0" | sed 's/^# \{0,1\}//'; }

# Load local config for HARETRAIL_DATA_DIR if not already set.
if [[ -z "$data_dir" && -f "$config_dir/config.env" ]]; then
  # shellcheck disable=SC1091
  set -a; . "$config_dir/config.env"; set +a
  data_dir="${HARETRAIL_DATA_DIR:-}"
fi

while [[ $# -gt 0 ]]; do
  case "$1" in
    --apply) apply=1; shift ;;
    --yes|-y) assume_yes=1; shift ;;
    --all) sel_claude=1; sel_codex=1; sel_kiro=1; any_sel=1; shift ;;
    --include-claude) sel_claude=1; any_sel=1; shift ;;
    --include-codex) sel_codex=1; any_sel=1; shift ;;
    --include-kiro) sel_kiro=1; any_sel=1; shift ;;
    --kiro-agent) kiro_agent="${2:?}"; shift 2 ;;
    --kiro-mode) kiro_mode="${2:?}"; shift 2 ;;
    --data-dir) data_dir="${2:?}"; shift 2 ;;
    --claude-home) claude_home="${2:?}"; shift 2 ;;
    --codex-home) codex_home="${2:?}"; shift 2 ;;
    --kiro-home) kiro_home="${2:?}"; shift 2 ;;
    --config-dir) config_dir="${2:?}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) printf 'Unknown option: %s\n' "$1" >&2; exit 2 ;;
  esac
done

if [[ -z "$data_dir" ]]; then
  printf 'No data dir. Pass --data-dir or set HARETRAIL_DATA_DIR.\n' >&2; exit 2
fi
if [[ ! -d "$data_dir" ]]; then
  printf 'Data dir does not exist: %s\n' "$data_dir" >&2; exit 2
fi
case "$kiro_mode" in scoped|broad) ;; *) printf 'Bad --kiro-mode: %s\n' "$kiro_mode" >&2; exit 2 ;; esac

# Default: target all detected tools.
if [[ "$any_sel" -eq 0 ]]; then sel_claude=1; sel_codex=1; sel_kiro=1; fi

note() { printf '  %s\n' "$*"; }
act()  { if [[ "$apply" -eq 1 ]]; then printf '  [applied] %s\n' "$*"; else printf '  [dry-run] %s\n' "$*"; fi; }
backup() { [[ "$apply" -eq 1 ]] && cp "$1" "$1.bak.$ts" && printf '  [backup] %s\n' "$1.bak.$ts"; }

printf 'HARE Trail: grant data-repo access (parity with cwd)\n'
printf 'Data repo: %s\n' "$data_dir"
if [[ "$apply" -eq 0 ]]; then printf 'Mode: DRY-RUN (no changes; re-run with --apply)\n\n'; else printf '\n'; fi

# ---------------- Claude Code ----------------
grant_claude() {
  local f="$claude_home/settings.json"
  printf 'Claude Code (%s):\n' "$f"
  if ! command -v jq >/dev/null 2>&1; then note "jq not found; skipping Claude"; return; fi
  [[ -f "$f" ]] || { note "no settings.json; creating a minimal one"; [[ "$apply" -eq 1 ]] && printf '{}\n' > "$f"; }
  [[ -f "$f" ]] || { note "skip"; return; }
  act "permissions.defaultMode = acceptEdits (if unset)"
  act "permissions.additionalDirectories += [\"$data_dir\"]"
  act "permissions.allow += git init/add/commit/status/log/diff/show/branch/checkout/restore, mkdir, ln, touch, cp, mv"
  if [[ "$apply" -eq 1 ]]; then
    backup "$f"
    jq --arg d "$data_dir" '
      .permissions = (.permissions // {})
      | .permissions.defaultMode = (.permissions.defaultMode // "acceptEdits")
      | .permissions.additionalDirectories = (((.permissions.additionalDirectories // []) + [$d]) | unique)
      | .permissions.allow = (((.permissions.allow // []) + [
          "Bash(git init:*)","Bash(git add:*)","Bash(git commit:*)","Bash(git status:*)",
          "Bash(git log:*)","Bash(git diff:*)","Bash(git show:*)","Bash(git branch:*)",
          "Bash(git checkout:*)","Bash(git restore:*)","Bash(mkdir:*)","Bash(ln:*)",
          "Bash(touch:*)","Bash(cp:*)","Bash(mv:*)"
        ]) | unique)
    ' "$f" > "$f.tmp.$ts" && mv "$f.tmp.$ts" "$f"
    jq -e . "$f" >/dev/null && note "valid JSON after edit"
  fi
  note "note: file edits use defaultMode=acceptEdits; additionalDirectories makes the data repo writable when launched elsewhere."
  printf '\n'
}

# ---------------- Codex CLI ----------------
grant_codex() {
  local f="$codex_home/config.toml"
  printf 'Codex CLI (%s):\n' "$f"
  [[ -f "$f" ]] || { note "no config.toml; skip"; printf '\n'; return; }
  local has_trust has_swr
  has_trust=$(grep -cF "[projects.\"$data_dir\"]" "$f" || true)
  has_swr=$(grep -cE '^\[sandbox_workspace_write\]' "$f" || true)
  if [[ "$has_trust" -ge 1 ]]; then note "data repo already a trusted project (trust_level) — ok"; else
    act "add [projects.\"$data_dir\"] trust_level = \"trusted\""; fi
  if [[ "$has_swr" -ge 1 ]]; then
    note "WARNING: [sandbox_workspace_write] already exists — not editing it automatically."
    note "         Ensure its writable_roots includes: $data_dir"
  else
    act "append [sandbox_workspace_write] writable_roots = [\"$data_dir\"]"
  fi
  if [[ "$apply" -eq 1 ]]; then
    backup "$f"
    {
      printf '\n# >>> haretrail:data-write (generated %s) >>>\n' "$ts"
      printf '# Parity-with-cwd access for the HARE Trail data repo. Remove this block to revert.\n'
      if [[ "$has_trust" -lt 1 ]]; then
        printf '[projects."%s"]\ntrust_level = "trusted"\n' "$data_dir"
      fi
      if [[ "$has_swr" -lt 1 ]]; then
        printf '[sandbox_workspace_write]\nwritable_roots = ["%s"]\n' "$data_dir"
      fi
      printf '# <<< haretrail:data-write <<<\n'
    } >> "$f"
    python3 -c "import tomllib,sys; tomllib.load(open('$f','rb')); print('  valid TOML after edit')"
  fi
  note "note: writable_roots takes effect under sandbox_mode=workspace-write (Codex default for trusted work)."
  note "      .git is force read-only by Codex itself — same as any cwd, so parity holds."
  printf '\n'
}

# ---------------- Kiro CLI ----------------
grant_kiro() {
  local f="$kiro_home/agents/$kiro_agent.json"
  printf 'Kiro CLI (%s, mode=%s):\n' "$f" "$kiro_mode"
  if ! command -v jq >/dev/null 2>&1; then note "jq not found; skipping Kiro"; return; fi
  [[ -f "$f" ]] || { note "no agent config; skip"; printf '\n'; return; }
  if [[ "$kiro_mode" == "scoped" ]]; then
    act "toolsSettings.write.allowedPaths += [\"$data_dir/**\"]"
    act "toolsSettings.shell.allowedCommands += git/mkdir/ln/touch/cp/mv regexes"
    note "scoped path/command auto-approve; write/shell NOT added to allowedTools (that would un-scope)."
    note "VERIFY in a fresh Kiro session: if writes in the data repo still prompt, this Kiro build may"
    note "not honor write path-scoping — re-run with --kiro-mode broad."
    if [[ "$apply" -eq 1 ]]; then
      backup "$f"
      jq --arg d "$data_dir" '
        .toolsSettings = (.toolsSettings // {})
        | .toolsSettings.write = (.toolsSettings.write // {})
        | .toolsSettings.write.allowedPaths = (((.toolsSettings.write.allowedPaths // []) + [$d + "/**"]) | unique)
        | .toolsSettings.shell = (.toolsSettings.shell // {})
        | .toolsSettings.shell.allowedCommands = (((.toolsSettings.shell.allowedCommands // []) + [
            "^git (init|add|commit|status|log|diff|show|branch|checkout|restore|rm|mv) .*",
            "^git (status|log|diff|branch)$",
            "^mkdir( -p)? .*","^ln (-s|-sf) .*","^touch .*","^cp .*","^mv .*"
          ]) | unique)
      ' "$f" > "$f.tmp.$ts" && mv "$f.tmp.$ts" "$f"
    fi
  else
    act "allowedTools += [\"write\",\"shell\"] (GLOBAL auto-approve, not path-scoped)"
    note "broad mode: write/shell auto-approved everywhere for this agent. Safety net = local git + frequent commits."
    if [[ "$apply" -eq 1 ]]; then
      backup "$f"
      jq '.allowedTools = (((.allowedTools // []) + ["write","shell"]) | unique)' "$f" > "$f.tmp.$ts" && mv "$f.tmp.$ts" "$f"
    fi
  fi
  if [[ "$apply" -eq 1 ]] && command -v kiro-cli >/dev/null 2>&1; then
    kiro-cli agent validate --path "$f" >/dev/null && note "kiro-cli agent validate: OK"
  fi
  printf '\n'
}

run_selected() {
  [[ "$sel_claude" -eq 1 ]] && grant_claude
  [[ "$sel_codex" -eq 1 ]] && grant_codex
  [[ "$sel_kiro" -eq 1 ]] && grant_kiro
  return 0
}

if [[ "$apply" -eq 1 ]]; then
  # Informed consent: show exactly what will be granted, then ask before writing.
  saved_apply=1; apply=0
  printf 'The following permissions will be granted — parity with a trusted current\n'
  printf 'working directory, scoped to the data repo. Symlinks stay allowed. Every\n'
  printf 'edited config is backed up first, and the change is reversible.\n\n'
  run_selected
  apply="$saved_apply"
  if [[ "$assume_yes" -ne 1 ]]; then
    if [[ -t 0 ]]; then
      printf 'Grant these permissions now? [y/N] '
      read -r _ans || _ans=""
      case "$_ans" in
        [yY]|[yY][eE][sS]) printf '\n' ;;
        *) printf 'Aborted by user. No changes made.\n'; exit 0 ;;
      esac
    else
      printf 'Non-interactive shell: not applying without consent. Re-run with --yes to confirm.\n' >&2
      exit 3
    fi
  else
    printf '(--yes given: consent assumed, applying)\n\n'
  fi
  run_selected
else
  run_selected
fi

printf 'Done (%s).\n' "$([[ "$apply" -eq 1 ]] && echo applied || echo 'dry-run; re-run with --apply')"
printf 'Revert: restore the .bak.%s files, or remove the marked blocks / added keys.\n' "$ts"
