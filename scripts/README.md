# Scripts

Reusable setup and maintenance scripts live here.

Status: Phase 3 migration started.

Available scripts:

- `install-connectors.sh`: install HARE Trail skill symlinks for local agent tools.

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
