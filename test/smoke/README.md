# Clean-checkout smoke test

A containerized smoke test for the HARE Trail install path. It validates that a
**clean checkout** can scaffold a data repo and install every connector against
disposable paths, without touching a real home directory or the system repo.

This covers the post-release items "validate a clean-checkout install path" and
"Docker/container smoke validation" from the README status list.

## What it checks

Inside a minimal Debian container (bash, git, jq, python3) it clones a clean
checkout and runs the real scripts against `/work/sandbox`:

- `init-data-repo.sh`: dry-run writes nothing; real run creates the data
  scaffold, an initial research task folder and a git repo; re-run is
  idempotent; refuses unsafe targets like `$HOME`.
- `install-connectors.sh` (source mode): creates resolvable skill symlinks.
- `install-connectors.sh` (wrapper mode + `--write-config`): wrapper `SKILL.md`
  files point to canonical sources and carry the data dir; `config.env` is written.
- `install-connectors.sh --include-kiro-cli`: emits a valid Kiro agent JSON
  referencing `skill://` sources and `file://` data-repo rules.
- `install-connectors.sh --include-kiro-ide`: emits steering, skill wrappers and
  a valid multi-root `.code-workspace`.
- `grant-data-access.sh`: dry-run for all tools; `--apply --yes` keeps Claude
  `settings.json` / Codex `config.toml` / Kiro agent JSON valid and scoped to the
  data repo; refuses non-interactive apply without `--yes`.
- A leak guard asserting no private host paths or company references in the checkout.

## Portability

This harness encodes none of our local setup. It uses whatever Docker-compatible
runtime your active `docker` context points to — Colima, Docker Desktop, a remote
engine, etc. Colima below is only an example; no machine-specific path or runtime
choice is baked in — you pick the runtime.

## Run it

Requires a running Docker-compatible runtime. Colima is one option:

```bash
colima start            # if not already running
test/smoke/run-smoke.sh
```

Test the published GitHub repo instead of the local working tree:

```bash
test/smoke/run-smoke.sh --github
test/smoke/run-smoke.sh --github --ref main
```

The script builds `haretrail-smoke:latest`, then runs the container. Exit code
is non-zero if any check fails; the summary prints `PASS`/`FAIL` counts.

## Files

- `Dockerfile` — minimal image with the scripts' runtime dependencies.
- `container-smoke.sh` — the checks; runs inside the container.
- `run-smoke.sh` — host helper that builds the image and runs the container.

The repo is never copied into the image. The container clones `${SRC:-/src}`
(the read-only bind mount by default), so the test always runs committed state.
