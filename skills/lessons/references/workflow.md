# Lessons workflow

## Canonical paths

`{data-repo}` — root of the private HARE Trail data repo. Resolve it through `HARETRAIL_DATA_DIR`, then the current workspace if it has the expected data shape, then an explicit user/host-tool path. Do not hardcode personal absolute paths.

- `LESSONS.md`: `{data-repo}/LESSONS.md`
- Debriefs: `{data-repo}/session-debriefs/`
- Work artifacts: `{data-repo}/work-artifacts/`

## When to use

Use when the user asks to:

- show lessons;
- add a lesson;
- refine an existing lesson;
- regroup lessons.

## Modes

### Read

- show the relevant sections from `LESSONS.md`;
- if needed, reference related debrief/task artifacts.

### Write

- add a lesson only if it is genuinely confirmed;
- do not bloat `LESSONS.md` with noise;
- if a full analysis is needed, suggest or use `debrief`.

## Principle

`lessons` is a layer of distilled patterns, not a place for a detailed chronicle.
