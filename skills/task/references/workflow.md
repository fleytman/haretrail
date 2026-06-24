# Task workflow

## Canonical paths

`{data-repo}` — root of the private HARE Trail data repo. Resolve it through `HARETRAIL_DATA_DIR`, then the current workspace if it has the expected data shape, then an explicit user/host-tool path. Do not hardcode personal absolute paths.

- Entry point: `{data-repo}/AGENTS.md`
- Base rules: `{data-repo}/BASE.md`
- Task-folder model: `{data-repo}/work-artifacts/README.md`
- Task-folder directory: `{data-repo}/work-artifacts/`

## Goal

Do not start complex work "just in the chat" if the user wants it to be tracked as a separate task.

Result:

- a single task-folder is found or created;
- it has `README.md`, `tracker.md`, `journal.md`;
- if needed, `sources/`, `file-summaries/`, `prompts/`, `pr/`, `verification/` are created.
- if raw sources were migrated into the folder, they must get at least one `file-summaries/packet-summary.md`.

## 1. Find or create

Priority:

1. If the user gave an explicit path or slug, use it.
2. Otherwise look for similar folders in `work-artifacts/`.
3. If several plausible candidates are found and the risk of a mistake is high, ask the user.
4. If nothing is found, create `{slug}/`.

Default placement:

- By default a new task-folder is created in `{data-repo}/work-artifacts/`.
- If the user explicitly asks to create the artifact in the current workspace/repo, use the specified location and record this in `README.md`.
- If a task-folder is created in `{data-repo}` from the context of an external working repo and it will likely be revisited in future sessions, suggest that the user create an `ln -s` in the current repo for convenient access. Do not create the symlink silently.
- A new significant task-folder should be a local git repo by default, unless it is tiny/throwaway. If the repo author identity is ambiguous, ask the user or apply the local data config.
- If the task-folder is a git repo, new files that clearly belong to the current task must be added to the index (`git add <files>`) before the work is finished; do not stage unrelated user changes.

## 2. Minimal structure

A new task-folder must have:

```text
README.md
tracker.md
journal.md
```

Optional:

```text
sources/
file-summaries/
prompts/
pr/
verification/
architecture/
```

For legacy import / repack the following is also appropriate:

```text
migration-log.md
```

If source documents are imported into the task-folder:

- the literal build/app-wrapper path should not become the canonical storage path without a reason;
- `prompts/` should not be created automatically unless the user explicitly asked for prompt artifacts.

## 3. What to write

`README.md`

- what this task is;
- why it was opened;
- which repos/materials are related;
- source period / export date, if this is a migrated packet;
- where to look next.

`tracker.md`

- current question;
- current decisions;
- open questions;
- next step.

`journal.md`

- append-only entries;
- each entry is tagged not only with date/time but also with the **agent and
  session id** under which the work was done (for example
  `27.05.2026 [Claude Code (Opus 4.7), session 717744a5]`). This is needed so
  that traces are easier to find later in session logs
  (`~/.claude/projects/**/*.jsonl`, `~/.codex/sessions/**`);
- forks;
- progress updates;
- important quotes.

`migration-log.md`

- for a legacy import or a large migration, records:
  - source dates;
  - export/import timestamp;
  - mapping `from -> to`;
  - precision of the available dates.

## 4. If the user just says "let's keep this in a task folder"

Default behavior:

- suggest an existing task-folder if it clearly fits;
- otherwise create a new one and put the starting context there.

## 5. Relation to other skills

- `summary` can populate the task-folder with sources and file summaries;
- `research` can keep the tracker/journal inside the task-folder;
- `doc-write` can use the task-folder as a source for clean docs;
- `debrief` can read the task-folder as additional material.
