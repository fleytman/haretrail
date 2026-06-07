# Integrations

Host-tool integration wrappers will live here.

Status: Phase 3 migration started.

Available surfaces:

- source skill folders in `skills/`;
- connector installer in `scripts/install-connectors.sh`;
- optional Claude source symlinks via installer flag;
- generated thin wrappers through `scripts/install-connectors.sh --mode wrapper`.

Planned surfaces:

- runtime validation for Claude and Codex;
- setup validation scripts.

Integration rules:

- do not hardcode private data paths;
- connect to the data repo through explicit configuration;
- keep real private artifacts outside this repository.

## Current Limitation

`scripts/install-connectors.sh` can install symlinks to reusable source skill folders or generated thin wrappers with local `HARETRAIL_DATA_DIR` context.

Actual Claude/Codex runtime loading still needs fresh-session validation.
