# Postmortem workflow

## Canonical paths

`{data-repo}` — root of the private HARE Trail data repo. Resolve it through `HARETRAIL_DATA_DIR`, then the current workspace if it has the expected data shape, then an explicit user/host-tool path. Do not hardcode personal absolute paths.

- Postmortems directory: `{data-repo}/postmortems/`
- Postmortems README: `{data-repo}/postmortems/README.md`
- Lessons: `{data-repo}/LESSONS.md`

## When to use

Use only for heavy cases that need a detailed incident analysis.

## Format

```markdown
# {Title} Postmortem

Date: DD.MM.YYYY HH:mm:ss.SSS
Scope:
Status:
Report Type: Auto-report
Report Author: {Agent}
Agent Runtime Label: {exact label if known, else `not recorded`}
User Label: {preferred user label or `User`}
Narrative Mode: actor-labeled

## Summary
## Timeline
## Impact
## 5 Whys
## Winback Plan
## Lessons Learned
## Other Details
```

## Principle

- Not every mistake deserves a postmortem.
- `postmortem` = heavy, explicit, structured, incident-grade.
- Session-level mistakes usually go into `debrief`.
- In auto-generated postmortems the agent does not write an impersonal `I`; use explicit actor labels.
- In `Timeline`, right after `Summary`, aim to write exact timestamps; if the exact time is unavailable, explicitly state the available precision.
- In `Timeline` use exact quotes when they are critical to the turn of the situation.
- `5 Whys` can be given as a draft from the agent by default, but it should be an area the user can refine or rewrite.
