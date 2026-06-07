# Scripts

Reusable setup and maintenance scripts live here.

Status: Phase 3 migration started.

Available scripts:

- `install-connectors.sh`: install HARE Trail skill symlinks for local agent tools.
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

Install Codex and agents skill links:

```bash
./scripts/install-connectors.sh --data-dir /path/to/haretrail-data
```

Optional Claude source links:

```bash
./scripts/install-connectors.sh --include-claude --data-dir /path/to/haretrail-data
```

The Claude path currently links the reusable source skill folders. Tool-specific Claude wrappers are still future work.

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

The script creates missing files and keeps existing files. It does not copy private corpus, does not write to real home directories and does not initialize Windows-specific support yet.
