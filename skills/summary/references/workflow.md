# Summary workflow

## Canonical paths

`{data-repo}` — root of the private HARE Trail data repo. Resolve it through `HARETRAIL_DATA_DIR`, then the current workspace if it has the expected data shape, then an explicit user/host-tool path. Do not hardcode personal absolute paths.

- Entry point: `{data-repo}/AGENTS.md`
- Base rules: `{data-repo}/BASE.md`
- Task-folder and source-packet directory: `{data-repo}/work-artifacts/`
- Durable notes template: `{data-repo}/notes/README.md`

## When to use

Use this workflow when the user asks to:

- summarize a batch of files;
- work through many documents;
- process exported chats, notes or results from external AIs;
- store processed materials so they can be reused;
- do import + sources + summaries + quotes + prompts.

## Goal

The input is a packet of files.

The output should be a task-folder that contains:

- `sources/` — copies of the input files and only good-quality conversions;
- `file-summaries/` — summaries per document;
- `README.md` — overall summary of the packet;
- `prompts/` — prompts for further research AIs, only if the user explicitly asked to create them or the summary is part of an explicitly requested research packet;
- if needed, `tracker.md` and `journal.md`, when the packet is tied to a live task.

## 0. If the packet context is unclear

If the request does not make clear:

- why the user is assembling the packet;
- whether a per-file summary is needed or only a master summary;
- whether prompts for external AIs are needed;
- whether this is a standalone packet or part of an existing task;
- whether this is a `navigator overlay` or a `full repack` for legacy migration;

then first ask short clarifying questions. Do not turn it into a long questionnaire.

### Legacy migration modes

If the user is migrating an old note system or an old packet of working markdown files:

- `navigator overlay`
  - originals remain the primary source of depth;
  - new docs provide a map, summary, links and reading order.
- `full repack`
  - originals are kept in `sources/` only as an archive;
  - new docs should become a full replacement for the old structure;
  - it is acceptable to freely rearrange the content: `1 -> N`, `N -> 1`, introduce new file types for the task.

## 1. Determine the container

1. If the user gave an explicit task-folder slug or path, use it.
2. Otherwise create a new folder in `work-artifacts/` using the scheme:
   - `{slug}/`
3. If the packet already belongs to an existing task, update the existing task-folder rather than creating a new one.

## 2. Minimal structure

If the folder is new, create:

```text
{task-folder}/
  README.md
  tracker.md
  journal.md
  migration-log.md   # if this is a legacy import / repack
  sources/
  file-summaries/
```

`tracker.md` and `journal.md` can be short, but they must exist if the packet is tied to ongoing work.

Create `prompts/` only when explicitly needed by the user request or by the type of task.

## 3. Copy the sources

### General rule

- Do not delete or rewrite originals.
- Copy into `sources/`, preserving a clear structure.
- For repo-local files it is useful to preserve the repository and the relative path.
- If the source path is inside `build/`, `.cache/`, `.app`, `Frameworks/` and similar technical containers, do not copy the literal wrapper path without a reason; store a logically normalized path in `sources/` and record the original path in `sources/README.md` or `file-summaries/`.
- For exported chats and external note sources it is useful to preserve the source tool and the export date.
- For a legacy import, record separately:
  - source date / source period from the documents themselves;
  - export/import timestamp in `{data-repo}`;
  - precision of the dates that are actually available.
- For each imported file you need to remember:
  - the source path;
  - the file type;
  - what it was converted with, if there was a conversion;
  - tracked/untracked, if the file came from a git repository.

### Conversations and prompts

- If the input is an exported chat, store the raw export in `sources/`.
- If the input is a large prompt or a prompt pack, store the raw version in `sources/` or alongside in `prompts/` as the original artifact.
- If a cleaner reusable prompt emerges from the raw prompt, store it separately in `prompts/` instead of overwriting the original.

### Formats

- `.md`, `.txt` — copy as is
- `.pdf` — convert only if it produces structurally readable markdown/html/other semantically useful text
- `.docx` — convert only if it produces structurally readable markdown/html/other semantically useful text
- `.xlsx`, `.ods`, `.csv` — copy the original; if the format can be parsed without much loss of structure, make a sheet/column summary or a clean markdown preview rather than a low-quality text dump
- other formats — copy the original and record separately that no conversion was done

If there is no suitable tool:

- do not invent a fake conversion;
- do not store low-quality `.converted.txt` as a canonical source;
- for tabular files prefer a summary of the workbook/table structure over the original rather than a lossy plain-text flattening;
- record this in `README.md` and `tracker.md` as a tooling gap;
- ask the user only if a good-quality summary is impossible without it.

## 4. Make the summaries

### Overall packet summary

In `README.md` record:

- why the packet was assembled;
- which files went in;
- the main conclusion;
- source period, if this is a migrated packet;
- export/import date separately from the historical dates of the sources;
- the main clusters/themes;
- a mermaid diagram of the links between files, themes and output artifacts;
- which prompts were generated.

### Per-document summaries

By default make a single master file:

- `file-summaries/packet-summary.md`

If the packet is very large or the documents will be reused individually, you can additionally make:

- `file-summaries/{slug}.md` per document.

For each document record:

- the path to the original;
- a short description;
- source date / period, if known;
- export/import date separately, if the document was migrated from another system;
- key thoughts;
- why the document matters;
- what is worth reusing from it;
- important quotes.

## 5. Quotes

Add only short quotes if they genuinely help to:

- preserve the author's wording;
- retain a constraint;
- avoid losing a contradiction;
- convey style and intent.

Do not turn the summary into a long pile of quotes.

## 6. Mermaid

If the packet is multi-layered, add to `README.md` or `file-summaries/packet-summary.md` a single mermaid diagram:

- data flows;
- links between documents;
- the transition `sources -> summary -> research -> prompts -> notes` when needed.

## 7. Prompts

If further work is implied after the summary, create `prompts/*.md` only when:

- the user explicitly asked for prompts;
- the summary is part of an explicitly requested `research packet` for external AIs.

Typical prompts:

- critique prompt;
- deep research prompt;
- comparison prompt;
- prompt to extract durable notes;
- prompt to prepare a lecture or docs.

## 8. Versioning

In the main files use at minimum:

- `Created`
- `Updated`
- `Version`

If a file is updated repeatedly, do not erase the previous meaning; append a change log or new sections.

By default use the system time format:

- `DD.MM.YYYY HH:mm:ss.SSS`
