# System Behavior

This document captures reusable HARE Trail behavior that should apply across installations.

Local data repositories may override preferences such as language, paths and project-specific conventions. They should not silently become the only home for rules that improve the reusable system.

## Core Principles

- Preserve the path of work, not only final outputs.
- Keep artifacts human-readable first and agent-readable second.
- Prefer inspectable files over opaque runtime memory as the source of truth.
- Record evidence for important claims.
- Keep source boundaries visible: raw sources, summaries, prompts, decisions and lessons are different layers.
- Treat debriefs and lessons as tools for calibration and error prevention, not as blame logs.

## Progressive Disclosure

HARE Trail should make context cheap to re-enter:

1. Read README/status first.
2. Read tracker/current decisions next.
3. Read summaries and verification artifacts before raw sources.
4. Read long journals and raw source packets only when needed.

This keeps agent context bounded while preserving a full audit trail for humans.

## Artifact Boundaries

Reusable system repository:

- skills;
- templates;
- scripts;
- public docs;
- sanitized examples;
- integration contracts.

Private data repository:

- work artifacts;
- notes;
- session debriefs;
- lessons;
- postmortems;
- imported sources;
- user or project overlays.

If a file cannot be published without exposing private work, personal history, company context or local paths, it belongs in the data repository, not in the system repository.

## Writing Rules

- Use the user language or the active project language for working artifacts.
- If the target project has explicit documentation or language rules, follow the target project.
- In debriefs, name actors explicitly: for example `Codex`, `Claude Code`, `User`.
- In mutable documents, anchor relative words such as `current`, `new`, `recent` and `latest` with dates when the meaning can drift.
- For imported materials, distinguish source date, source period and import/export date.
- Avoid treating implementation compromises as identity labels. File-first markdown is the current primary layer, not the whole philosophy.

## Verification Behavior

- Verify real behavior, not only exit codes.
- Treat plausible claims as hypotheses until verified or attributed.
- When the user asks a question, answer with alternatives unless they clearly asked for implementation.
- Before destructive filesystem changes, verify both data safety and runtime safety.
- Data safety means backup, checksum, restore or sync evidence.
- Runtime safety means current sessions, working directories, config, skill discovery and symlink targets will not be broken by the operation.

## Git Hygiene For Work Artifacts

- `work-artifacts/*` may be standalone git repositories.
- When creating or editing files inside a work-artifact that is a git repository, stage files that clearly belong to the current change with `git add` before reporting the work as complete.
- Do not stage unrelated user changes, generated noise, ignored files or files whose relation to the current change is unclear.
- If a new significant work-artifact is created as a git repository, set or verify the repository-local git identity before the first commit when local policy requires it.
- If staging is blocked by permissions or tool sandboxing, report that clearly and retry with the normal permission-escalation flow when appropriate.

## Lessons And Debriefs

Lessons should be:

- evidence-backed;
- scoped to where they apply;
- linked to source debriefs or verification artifacts;
- concise enough to be useful at session start.

Debriefs should preserve:

- false hypotheses;
- participant-specific mistakes;
- user corrections;
- verified root cause;
- what changed in future behavior.

## Local-To-System Escalation

When a user or agent changes a local data-repo rule, decide whether it is:

- local preference: keep it in the data repository;
- reusable best practice: prepare a system-repo change;
- uncertain design decision: create an issue/discussion prompt before changing the public system.

Agents should not silently bury reusable improvements in private local config. They should ask whether to keep the rule local, open an issue, or prepare a pull request.

## Future Runtime Layers

Search, embeddings, MCP, graph projections and runtime memory can be added later. They should remain layers over inspectable artifacts, not replacements for the human-readable source of truth.
