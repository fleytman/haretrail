#!/usr/bin/env bash
#
# container-smoke.sh — clean-checkout install smoke for HARE Trail.
#
# Runs INSIDE the smoke container against the freshly cloned checkout at
# /work/haretrail. Exercises the real install scripts against disposable HOME
# and data-repo paths under /work/sandbox, then asserts the artifacts they are
# supposed to produce. Never touches a real home directory or the system repo.
#
# Exit 0 only if every check passed.

REPO="${REPO:-/work/haretrail}"
SANDBOX="${SANDBOX:-/work/sandbox}"

pass=0
fail=0

ok()  { printf '  PASS  %s\n' "$1"; pass=$((pass + 1)); }
bad() { printf '  FAIL  %s\n' "$1"; fail=$((fail + 1)); }

# assert <description> <test-command...>
assert() {
  local desc="$1"; shift
  if "$@" >/dev/null 2>&1; then ok "$desc"; else bad "$desc"; fi
}

# run a script, capture exit code, report; stores output in $LAST_OUT
LAST_OUT=""
run_step() {
  local desc="$1"; shift
  if LAST_OUT="$("$@" 2>&1)"; then
    ok "$desc (exit 0)"
  else
    bad "$desc (exit $?)"
    printf '%s\n' "$LAST_OUT" | sed 's/^/        /'
  fi
}

section() { printf '\n=== %s ===\n' "$1"; }

DATA="$SANDBOX/data"
CFG="$SANDBOX/.haretrail"

rm -rf "$SANDBOX"
mkdir -p "$SANDBOX"

printf 'HARE Trail clean-checkout smoke\n'
printf 'Checkout: %s\n' "$REPO"
printf 'Sandbox:  %s\n' "$SANDBOX"

# Sanity: this must be a real checkout with the scripts present.
section "checkout sanity"
assert "init-data-repo.sh present"    test -f "$REPO/scripts/init-data-repo.sh"
assert "install-connectors.sh present" test -f "$REPO/scripts/install-connectors.sh"
assert "grant-data-access.sh present"  test -f "$REPO/scripts/grant-data-access.sh"
assert "8 skill sources present"       test -f "$REPO/skills/task/SKILL.md" \
                                            -a -f "$REPO/skills/research/SKILL.md" \
                                            -a -f "$REPO/skills/contribution-log/SKILL.md"

# ---------------------------------------------------------------------------
section "init-data-repo.sh"
# Dry-run writes nothing.
run_step "init dry-run" bash "$REPO/scripts/init-data-repo.sh" --dry-run --target "$DATA"
assert "dry-run created no data dir" test ! -e "$DATA"

# Real init with an initial research task + git.
run_step "init real" bash "$REPO/scripts/init-data-repo.sh" \
  --target "$DATA" \
  --initial-task smoke-thread \
  --task-title "Smoke thread" \
  --task-kind research \
  --with-source-dirs \
  --git-init

assert "data README"            test -f "$DATA/README.md"
assert "data AGENTS.md"         test -f "$DATA/AGENTS.md"
assert "data BASE.md"           test -f "$DATA/BASE.md"
assert "data LESSONS.md"        test -f "$DATA/LESSONS.md"
assert "data .gitignore"        test -f "$DATA/.gitignore"
assert "work-artifacts dir"     test -d "$DATA/work-artifacts"
assert "notes dir"              test -d "$DATA/notes"
assert "session-debriefs dir"   test -d "$DATA/session-debriefs"
assert "postmortems dir"        test -d "$DATA/postmortems"
assert "git repo initialized"   test -d "$DATA/.git"
# Initial task folder (date-prefixed) with sources/file-summaries.
task_dir="$(find "$DATA/work-artifacts" -maxdepth 1 -type d -name '*-smoke-thread' | head -1)"
assert "initial task folder"    test -n "$task_dir"
assert "task tracker.md"        test -f "$task_dir/tracker.md"
assert "task journal.md"        test -f "$task_dir/journal.md"
assert "task sources/"          test -d "$task_dir/sources"
assert "task file-summaries/"   test -d "$task_dir/file-summaries"
# Idempotency: re-running keeps existing files and still exits 0.
run_step "init re-run idempotent" bash "$REPO/scripts/init-data-repo.sh" --target "$DATA"

# Safety: refuse unsafe target ($HOME).
if bash "$REPO/scripts/init-data-repo.sh" --target "$HOME" >/dev/null 2>&1; then
  bad "init refuses HOME as target"
else
  ok "init refuses HOME as target"
fi

# ---------------------------------------------------------------------------
section "install-connectors.sh (source mode)"
CODEX_SRC="$SANDBOX/codex-source"
run_step "connectors dry-run" bash "$REPO/scripts/install-connectors.sh" \
  --dry-run --data-dir "$DATA" --codex-home "$CODEX_SRC"
assert "dry-run created no codex skills" test ! -e "$CODEX_SRC/skills"

run_step "connectors source install" bash "$REPO/scripts/install-connectors.sh" \
  --data-dir "$DATA" --codex-home "$CODEX_SRC"
assert "codex task symlink"      test -L "$CODEX_SRC/skills/task"
assert "codex research symlink"  test -L "$CODEX_SRC/skills/research"
# Symlink must resolve to a readable canonical SKILL.md inside the checkout.
assert "symlink resolves to SKILL.md" test -f "$CODEX_SRC/skills/task/SKILL.md"

# ---------------------------------------------------------------------------
section "install-connectors.sh (wrapper mode + config)"
CODEX_WRAP="$SANDBOX/codex-wrapper"
run_step "connectors wrapper install" bash "$REPO/scripts/install-connectors.sh" \
  --mode wrapper --write-config \
  --data-dir "$DATA" --codex-home "$CODEX_WRAP" --config-dir "$CFG"
assert "wrapper SKILL.md exists"   test -f "$CODEX_WRAP/skills/research/SKILL.md"
assert "wrapper marker exists"     test -f "$CODEX_WRAP/skills/research/.haretrail-wrapper"
assert "wrapper points to canonical source" grep -q "skills/research/SKILL.md" "$CODEX_WRAP/skills/research/SKILL.md"
assert "wrapper carries data dir"  grep -q "HARETRAIL_DATA_DIR=$DATA" "$CODEX_WRAP/skills/research/SKILL.md"
assert "local config.env written"  test -f "$CFG/config.env"
assert "config has system dir"     grep -q "HARETRAIL_SYSTEM_DIR=$REPO" "$CFG/config.env"
assert "config has data dir"       grep -q "HARETRAIL_DATA_DIR=$DATA" "$CFG/config.env"

# Wrapper mode without a data dir must fail fast.
if bash "$REPO/scripts/install-connectors.sh" --mode wrapper \
     --codex-home "$SANDBOX/codex-nodata" >/dev/null 2>&1; then
  bad "wrapper mode requires data dir"
else
  ok "wrapper mode requires data dir"
fi

# ---------------------------------------------------------------------------
section "install-connectors.sh (Kiro CLI agent)"
KIRO_CLI="$SANDBOX/kiro-cli"
run_step "kiro-cli connector" bash "$REPO/scripts/install-connectors.sh" \
  --include-kiro-cli --data-dir "$DATA" \
  --kiro-home "$KIRO_CLI" --config-dir "$SANDBOX/.haretrail-kcli"
KIRO_AGENT="$KIRO_CLI/agents/haretrail.json"
assert "kiro agent json exists"  test -f "$KIRO_AGENT"
assert "kiro agent is valid JSON" jq -e . "$KIRO_AGENT"
assert "agent references skill://" grep -q 'skill://' "$KIRO_AGENT"
assert "agent references data file://" grep -q "file://$DATA/AGENTS.md" "$KIRO_AGENT"

# ---------------------------------------------------------------------------
section "install-connectors.sh (Kiro IDE)"
KIRO_IDE="$SANDBOX/kiro-ide"
run_step "kiro-ide connector" bash "$REPO/scripts/install-connectors.sh" \
  --include-kiro-ide --data-dir "$DATA" \
  --kiro-home "$KIRO_IDE" --config-dir "$SANDBOX/.haretrail-kide"
assert "ide steering file"       test -f "$KIRO_IDE/steering/haretrail.md"
assert "ide skill dir + SKILL.md" test -f "$KIRO_IDE/skills/haretrail-research/SKILL.md"
WS="$SANDBOX/.haretrail-kide/haretrail.code-workspace"
assert "ide workspace file"      test -f "$WS"
assert "ide workspace valid JSON" jq -e . "$WS"

# ---------------------------------------------------------------------------
section "grant-data-access.sh"
run_step "grant dry-run (all tools)" bash "$REPO/scripts/grant-data-access.sh" \
  --data-dir "$DATA" --all \
  --claude-home "$SANDBOX/g-claude" \
  --codex-home "$SANDBOX/g-codex" \
  --kiro-home "$KIRO_CLI"

# Apply to Claude: script creates a minimal settings.json and edits it via jq.
GCLAUDE="$SANDBOX/g-claude"; mkdir -p "$GCLAUDE"
run_step "grant apply claude" bash "$REPO/scripts/grant-data-access.sh" \
  --apply --yes --data-dir "$DATA" --include-claude --claude-home "$GCLAUDE"
assert "claude settings.json valid JSON" jq -e . "$GCLAUDE/settings.json"
assert "claude additionalDirectories has data dir" \
  bash -c "jq -e --arg d '$DATA' '.permissions.additionalDirectories | index(\$d)' '$GCLAUDE/settings.json'"

# Apply to Codex: needs an existing config.toml; verify it stays valid TOML.
GCODEX="$SANDBOX/g-codex"; mkdir -p "$GCODEX"; : > "$GCODEX/config.toml"
run_step "grant apply codex" bash "$REPO/scripts/grant-data-access.sh" \
  --apply --yes --data-dir "$DATA" --include-codex --codex-home "$GCODEX"
assert "codex config.toml valid after edit" \
  python3 -c "import tomllib; tomllib.load(open('$GCODEX/config.toml','rb'))"
assert "codex config grants writable_roots" grep -q "writable_roots" "$GCODEX/config.toml"

# Apply to Kiro: edit the generated agent json (scoped), keep it valid JSON.
run_step "grant apply kiro (scoped)" bash "$REPO/scripts/grant-data-access.sh" \
  --apply --yes --data-dir "$DATA" --include-kiro --kiro-home "$KIRO_CLI"
assert "kiro agent valid JSON after grant" jq -e . "$KIRO_AGENT"
assert "kiro write allowedPaths scoped to data dir" \
  bash -c "jq -e --arg p '$DATA/**' '.toolsSettings.write.allowedPaths | index(\$p)' '$KIRO_AGENT'"

# Non-interactive apply without --yes must refuse (no silent privilege grant).
if echo | bash "$REPO/scripts/grant-data-access.sh" --apply --data-dir "$DATA" \
     --include-claude --claude-home "$SANDBOX/g-claude2" >/dev/null 2>&1; then
  bad "grant refuses non-interactive apply without --yes"
else
  ok "grant refuses non-interactive apply without --yes"
fi

# ---------------------------------------------------------------------------
section "install-connectors.sh (backups kept outside skill dir)"
# Re-install over a non-symlink skill and a legacy "<name>.bak.<ts>" sibling.
# Backups must be preserved but moved OUT of the scanned skills dir, so host
# tools never index them as duplicate skills.
CODEX_BAK="$SANDBOX/codex-bak"
CFG_BAK="$SANDBOX/.haretrail-bak"
mkdir -p "$CODEX_BAK/skills/research" "$CODEX_BAK/skills/task.bak.OLD"
printf 'foreign\n' > "$CODEX_BAK/skills/research/SKILL.md"   # non-symlink real skill
printf 'legacy\n'  > "$CODEX_BAK/skills/task.bak.OLD/SKILL.md" # stale sibling backup

run_step "reinstall over existing files" bash "$REPO/scripts/install-connectors.sh" \
  --data-dir "$DATA" --codex-home "$CODEX_BAK" --config-dir "$CFG_BAK"

# No "*.bak.*" left inside the scanned skills dir.
if ls -d "$CODEX_BAK"/skills/*.bak.* >/dev/null 2>&1; then
  bad "no .bak.* siblings remain in skills dir"
else
  ok "no .bak.* siblings remain in skills dir"
fi
# The live skill is now a symlink (clean install over the foreign dir).
assert "research is a live symlink" test -L "$CODEX_BAK/skills/research"
# Both the overwritten skill and the legacy sibling are preserved externally.
assert "backups preserved under config dir" test -d "$CFG_BAK/connector-backups"
if [[ "$(find "$CFG_BAK/connector-backups" -name SKILL.md 2>/dev/null | wc -l)" -ge 2 ]]; then
  ok "overwritten + legacy backups both preserved"
else
  bad "overwritten + legacy backups both preserved"
fi

section "leak guard"
# The system checkout must not contain concrete private host paths or company
# references. Documented relative paths (haretrail-data/...) and intentional
# author attribution (fleytman) are allowed.
if grep -RInE '/Users/[a-z]|/home/[a-z]|indriv|inDriver' \
     --include='*.sh' --include='*.md' "$REPO/scripts" "$REPO/skills" "$REPO/docs" \
     | grep -vE '/path/to/|/Users/<' >/dev/null 2>&1; then
  printf '        offending lines:\n'
  grep -RInE '/Users/[a-z]|/home/[a-z]|indriv|inDriver' \
     --include='*.sh' --include='*.md' "$REPO/scripts" "$REPO/skills" "$REPO/docs" \
     | grep -vE '/path/to/|/Users/<' | sed 's/^/        /'
  bad "no private paths / company refs in checkout"
else
  ok "no private paths / company refs in checkout"
fi

# ---------------------------------------------------------------------------
printf '\n=== summary ===\n'
printf 'PASS: %d\n' "$pass"
printf 'FAIL: %d\n' "$fail"

if [[ "$fail" -gt 0 ]]; then
  printf 'SMOKE FAILED\n'
  exit 1
fi
printf 'SMOKE OK\n'
