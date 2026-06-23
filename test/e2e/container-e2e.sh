#!/usr/bin/env bash
#
# container-e2e.sh — behavioral runtime e2e for HARE Trail.
#
# Runs INSIDE the e2e container against the freshly cloned checkout. With a
# clean install in place, it drives each real agent through a HARE Trail
# workflow and asserts on the data-repo filesystem (durable evidence), not on
# chat text:
#
#   1. clean install            (done here in setup)
#   2. use the 'research' skill to create a task-folder structure
#   3. write artifacts inside the data repo's work-artifacts/
#   4. run whitelisted commands (git init / git add) in the artifact folder
#
# This makes live, paid API calls. Auth is provided by env tokens the host
# forwards (OPENAI_API_KEY for codex, CLAUDE_CODE_OAUTH_TOKEN or
# ANTHROPIC_API_KEY for claude). A tool without a token is skipped.
#
# Tool selection: E2E_TOOLS="codex,claude" (default both).
# Exit non-zero if a selected, token-present tool fails to produce the
# expected artifacts/commands, or errors on auth/CLI.

set -uo pipefail

REPO="${REPO:-/work/haretrail}"
SANDBOX="${SANDBOX:-/work/sandbox}"
TOOLS="${E2E_TOOLS:-codex,claude}"
DATE="$(date +%F)"
SLUG="container-probe"

pass=0
fail=0
rc=0
ok()   { printf '  PASS  %s\n' "$1"; pass=$((pass + 1)); }
bad()  { printf '  FAIL  %s\n' "$1"; fail=$((fail + 1)); rc=1; }
check(){ local d="$1"; shift; if "$@" >/dev/null 2>&1; then ok "$d"; else bad "$d"; fi; }
have() { case ",$TOOLS," in *",$1,"*) return 0;; *) return 1;; esac; }

prompt_for() {
  local d="$1"
  cat <<EOF
You are working in a HARE Trail data repository at: $d
A HARE Trail "research" skill is installed for you. Follow its workflow.

Do exactly these steps, using shell commands and file writes, and touch nothing
outside $d:
1) Create the research task folder: $d/work-artifacts/$DATE-$SLUG
2) Inside it create three files consistent with the research skill:
   - README.md   (a title and a one-line purpose)
   - tracker.md  (with sections "Current question" and "Next step")
   - journal.md  (one dated entry)
3) Initialize git in that task folder and stage the files: run "git init" then
   "git add -A" inside that folder.
4) As the final line of your reply, print: PROBE_DONE: $d/work-artifacts/$DATE-$SLUG

Keep it minimal.
EOF
}

assert_flow() {
  local tool="$1" d="$2" out="$3" ec="$4"
  local task="$d/work-artifacts/$DATE-$SLUG"

  printf '\n----- %s output (exit %s, last lines) -----\n' "$tool" "$ec"
  printf '%s\n' "$out" | tail -8 | sed 's/^/  /'
  printf '%s\n' "----- end $tool output -----"

  if [[ "$ec" -ne 0 ]] && printf '%s' "$out" \
       | grep -qiE 'not.*(logged|authenticated)|invalid.*key|unauthorized|401|403'; then
    bad "$tool: auth/CLI error (no usable run)"
    return
  fi

  # Step 2/3: skill-driven structure written into the artifact folder.
  check "$tool: task folder created"          test -d "$task"
  check "$tool: README.md written"            test -f "$task/README.md"
  check "$tool: tracker.md written"           test -f "$task/tracker.md"
  check "$tool: journal.md written"           test -f "$task/journal.md"
  # Step 2 evidence the research skill shaped it.
  check "$tool: tracker has 'Current question'" grep -qiF "Current question" "$task/tracker.md"
  # Step 4: whitelisted commands actually ran.
  check "$tool: git initialized in task folder" test -d "$task/.git"
}

printf 'HARE Trail behavioral runtime e2e\n'
printf 'Checkout: %s\n' "$REPO"
printf 'Tools:    %s\n' "$TOOLS"
printf 'Versions: node %s | claude %s | codex %s\n' \
  "$(node --version 2>/dev/null)" \
  "$(claude --version 2>/dev/null | head -1)" \
  "$(codex --version 2>/dev/null | head -1)"

# --- setup: clean install (connectors into the real agent homes) -------------
printf '\n[setup] installing connectors into ~/.codex and ~/.claude...\n'
BASE="$SANDBOX/data-base"
bash "$REPO/scripts/init-data-repo.sh" --target "$BASE" >/dev/null \
  || { printf 'init-data-repo (base) failed\n' >&2; exit 2; }
bash "$REPO/scripts/install-connectors.sh" --include-claude --data-dir "$BASE" >/dev/null \
  || { printf 'install-connectors failed\n' >&2; exit 2; }
printf '[setup] codex skills: %s\n' "$(ls "$HOME/.codex/skills" 2>/dev/null | tr '\n' ' ')"
printf '[setup] claude skills: %s\n' "$(ls "$HOME/.claude/skills" 2>/dev/null | tr '\n' ' ')"

# codex needs api-key auth stored (it does not read OPENAI_API_KEY directly).
if have codex && [[ -n "${OPENAI_API_KEY:-}" ]]; then
  printf '%s' "$OPENAI_API_KEY" | codex login --with-api-key >/dev/null 2>&1 \
    || printf '[codex] warning: api-key login returned non-zero\n'
fi

# --- codex -------------------------------------------------------------------
if have codex; then
  if [[ -z "${OPENAI_API_KEY:-}" ]]; then
    printf '\n[codex] skipped: OPENAI_API_KEY not provided\n'
  else
    D="$SANDBOX/data-codex"
    bash "$REPO/scripts/init-data-repo.sh" --target "$D" --git-init >/dev/null
    printf '\n[codex] running workflow probe...\n'
    out="$(codex exec --dangerously-bypass-approvals-and-sandbox --skip-git-repo-check \
            -C "$D" "$(prompt_for "$D")" </dev/null 2>&1)"; ec=$?
    assert_flow codex "$D" "$out" "$ec"
  fi
fi

# --- claude ------------------------------------------------------------------
if have claude; then
  if [[ -z "${CLAUDE_CODE_OAUTH_TOKEN:-}${ANTHROPIC_API_KEY:-}" ]]; then
    printf '\n[claude] skipped: no CLAUDE_CODE_OAUTH_TOKEN / ANTHROPIC_API_KEY\n'
  else
    D="$SANDBOX/data-claude"
    bash "$REPO/scripts/init-data-repo.sh" --target "$D" --git-init >/dev/null
    printf '\n[claude] running workflow probe...\n'
    out="$(cd "$D" && claude -p "$(prompt_for "$D")" \
            --output-format text --permission-mode bypassPermissions \
            --add-dir "$D" 2>&1)"; ec=$?
    assert_flow claude "$D" "$out" "$ec"
  fi
fi

# --- summary -----------------------------------------------------------------
printf '\n=== summary ===\n'
printf 'PASS: %d\n' "$pass"
printf 'FAIL: %d\n' "$fail"
if [[ "$rc" -ne 0 ]]; then
  printf 'E2E FAILED\n'
else
  printf 'E2E OK\n'
fi
exit "$rc"
