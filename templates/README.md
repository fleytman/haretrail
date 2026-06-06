# Templates

Reusable HARE Trail templates live here.

Status: Phase 3 migration started.

Available templates:

- `task-folder/`
- `summary-packet/`
- `research-task/`
- `contribution-log/`
- `debrief.md`
- `postmortem.md`
- `verification-artifact.md`

## Placeholder Convention

Templates use `{{placeholder}}` values for user-filled fields.

Common placeholders:

- `{{title}}`
- `{{slug}}`
- `{{created_date}}`
- `{{updated_date}}`
- `{{owner}}`
- `{{data_repo}}`
- `{{source_period}}`
- `{{status}}`

## Rules

- Keep templates generic and free of private project context.
- Do not include real work artifacts, real debriefs or private lessons.
- Prefer explicit uncertainty over polished but unsupported claims.
- Preserve source boundaries: originals, summaries and interpretations should stay distinguishable.
- Add prompts only when a workflow explicitly asks for prompt artifacts.
