# Skills

Reusable HARE Trail skills live here.

Status: Phase 3 migration started.

Migrated skill source folders:

- `task`
- `summary`
- `research`
- `doc-write`
- `debrief`
- `lessons`
- `postmortem`
- `contribution-log`

Current maturity:

- reusable source folders are present;
- hardcoded private paths have been replaced with `{data-repo}`;
- connector installation supports source links and generated thin wrappers;
- clean-checkout source-link setup is validated, wrapper-mode runtime loading still needs validation.

## Data Repo Placeholder

`{data-repo}` means the private HARE Trail data repository root.

Resolve it in this order:

1. `HARETRAIL_DATA_DIR`, if configured.
2. The current workspace, if it has the expected data repo shape.
3. An explicit path provided by the user or host-tool config.

Do not hardcode personal absolute paths in reusable skills. Do not silently write private artifacts from the system repo when `{data-repo}` is unresolved.
