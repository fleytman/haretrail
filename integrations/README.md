# Integrations

Host-tool integration wrappers will live here.

Status: Phase 3 migration started.

Available surfaces:

- source skill folders in `skills/`;
- connector installer in `scripts/install-connectors.sh`;
- optional Claude source symlinks via installer flag.

Planned surfaces:

- Claude skill wrappers;
- Codex-compatible skill layout;
- setup validation scripts.

Integration rules:

- do not hardcode private data paths;
- connect to the data repo through explicit configuration;
- keep real private artifacts outside this repository.

## Current Limitation

`scripts/install-connectors.sh` installs symlinks to reusable source skill folders. It does not yet generate tool-specific Claude wrappers and does not validate a clean checkout end-to-end.
