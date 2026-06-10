# Scripts

Reusable setup and maintenance scripts live here.

Status: Phase 3 migration started.

Available scripts:

- `install-connectors.sh`: install HARE Trail source links or generated thin wrappers for local agent tools.
- `init-data-repo.sh`: create a minimal private data repo or initial task scaffold.

Planned scripts:

- setup validator;
- path/config checker;
- smoke tests for sample data.

## `install-connectors.sh`

Use dry-run first:

```bash
./scripts/install-connectors.sh --dry-run --data-dir examples/fixture-data-repo
```

Install Codex source links:

```bash
./scripts/install-connectors.sh --data-dir /path/to/haretrail-data
```

Install generated thin wrappers and local config:

```bash
./scripts/install-connectors.sh \
  --mode wrapper \
  --write-config \
  --data-dir /path/to/haretrail-data
```

Optional Claude wrappers:

```bash
./scripts/install-connectors.sh \
  --mode wrapper \
  --write-config \
  --include-claude \
  --data-dir /path/to/haretrail-data
```

Optional Kiro CLI agent config (Kiro loads skills through an agent config, not a skills directory):

```bash
./scripts/install-connectors.sh \
  --include-kiro \
  --write-config \
  --data-dir /path/to/haretrail-data
```

This generates `~/.kiro/agents/haretrail.json` referencing canonical source skills via `skill://` and the data repo via `file://`. See `integrations/kiro/README.md`.

Optional agents wrappers, only when the target tool requires `~/.agents/skills` and does not also scan `~/.codex/skills`:

```bash
./scripts/install-connectors.sh \
  --mode wrapper \
  --write-config \
  --include-agents \
  --data-dir /path/to/haretrail-data
```

Wrapper mode writes small local `SKILL.md` files that point to canonical `haretrail/skills/<skill>/SKILL.md` and provide local `HARETRAIL_DATA_DIR` context. It does not copy private data into the system repo.

Scripts should use explicit configuration such as `HARETRAIL_DATA_DIR` when they need access to a data repository.

## `init-data-repo.sh`

Use dry-run first:

```bash
./scripts/init-data-repo.sh --dry-run --target /tmp/haretrail-data-demo
```

Create a minimal private data repo scaffold:

```bash
./scripts/init-data-repo.sh --target /path/to/haretrail-data
```

Create a data repo plus an initial task folder:

```bash
./scripts/init-data-repo.sh \
  --target /path/to/haretrail-data \
  --initial-task first-research-thread \
  --task-title "First research thread" \
  --task-kind research
```

The script creates missing files and keeps existing files. It does not copy private corpus, does not write to real home directories and does not initialize Windows-specific support yet. If `--git-init` is used, `work-artifacts/*` remains ignored by the parent data repo so task folders can be standalone repositories.
