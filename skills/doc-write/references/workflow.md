# Doc Write workflow

## Canonical paths

`{data-repo}` — root of the private HARE Trail data repo. Resolve it through `HARETRAIL_DATA_DIR`, then the current workspace if it has the expected data shape, then an explicit user/host-tool path. Do not hardcode personal absolute paths.

- Entry point: `{data-repo}/AGENTS.md`
- Base rules: `{data-repo}/BASE.md`
- Work artifacts: `{data-repo}/work-artifacts/`
- Durable notes: `{data-repo}/notes/`

## Goal

Make documentation:

- short;
- easy for a human to understand;
- consistent with the repository rules;
- without long code dumps;
- concrete enough to be usable.

## 1. First read the style of the target place

Before writing:

1. Find `AGENTS.md`, `README`, `docs/`, templates and neighboring documents.
2. Determine the language of the existing documentation.
3. Understand the audience:
   - the project team;
   - the user of local notes;
   - the author themselves as a future reader.

## 2. Default language

- For working engineering repositories, follow the target repository's explicit documentation and language rules; if they exist, the target project wins. If none are stated, match the language of the existing documentation in that repository.
- For personal notes, home tasks and data-repo artifacts, write in the language configured as HARETRAIL_ARTIFACT_LANG in the local config (~/.haretrail/config.env); if unset, fall back to the language of the current user/dialogue. Do not hardcode a specific language.

## 3. What to write

The doc should answer the reader's real questions:

- what it is;
- why it is needed;
- when to use it;
- how to run or apply it;
- what limitations and important nuances exist.

## 4. What to avoid

- long code inserts without a reason;
- retelling the diff file by file;
- unnecessary theory when the user needs working instructions;
- the AI's internal monologue;
- duplicating an already existing canonical doc.

## 5. Sources for the doc

Use:

- the code and neighboring docs in the repository;
- relevant work-artifacts;
- summaries and prompts, if the doc grew out of research;
- confirmed facts from the tracker/journal, not raw guesses.

## 6. If the document grows out of a working note

A common pattern:

- a raw note in `work-artifacts/`
- then a clean version in the repo docs

In this case:

- do not copy the working log into the documentation;
- extract only the durable knowledge;
- if there are important caveats, keep them short and to the point.
