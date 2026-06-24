# Contribution Log workflow

## Canonical paths

`{data-repo}` — root of the private HARE Trail data repo. Resolve it through `HARETRAIL_DATA_DIR`, then the current workspace if it has the expected data shape, then an explicit user/host-tool path. Do not hardcode personal absolute paths.

- Entry point: `{data-repo}/AGENTS.md`
- Base rules: `{data-repo}/BASE.md`
- Task-folder model: `{data-repo}/work-artifacts/README.md`
- Task-folder directory: `{data-repo}/work-artifacts/`

## When to use

Use when the user wants to:

- keep a contribution log;
- gather evidence for a self-review;
- record help given / help received;
- preserve glue work and other hard-to-quantify contribution;
- import a workbook/logbook such as `xlsx/csv/ods` with contribution history;
- prepare material for a conversation with a manager or a review without losing context.

## Principle

`contribution-log` is a layer of visibility into contribution and process, not a rating and not a performance dashboard.

Main principles:

- do not reduce contribution to counters;
- distinguish `countable` and `intangible` contribution;
- preserve exactly who the contribution was useful to and which problem it removed;
- keep help received and unfinished but significant work separately;
- store evidence links and short context, but do not turn the log into a long autobiography.

## 1. Find or create the container

Priority:

1. If the user gave an explicit folder or slug, use it.
2. Otherwise look for similar folders in `work-artifacts/`:
   - `contribution-log`
   - `self-review`
   - `work-visibility`
   - periodic variants such as `self-review-2026-h1`
3. If nothing is found, by default create:

```text
work-artifacts/contribution-log/
```

If the user is explicitly working by period, container names such as the following are acceptable:

```text
work-artifacts/self-review-2026-h1/
work-artifacts/contribution-log-2026/
```

## 2. Minimal structure

A new container must have:

```text
README.md
tracker.md
journal.md
logs/
  contributions.md
  received-help.md
  unfinished.md
```

Optional:

```text
sources/
file-summaries/
evidence/
prompts/
```

`evidence/` is appropriate for:

- screenshots;
- exported tables;
- pasted message drafts;
- supporting self-review artifacts.

If a workbook/logbook is imported, it must get at least one:

```text
file-summaries/packet-summary.md
```

## 3. What to write

`README.md`

- what this contribution log is;
- whose it is;
- which period it covers;
- why it is kept;
- where to look next;
- how to read the entries.

`tracker.md`

- the current period;
- what has already been gathered;
- which evidence gaps are missing;
- which sections need to be filled in;
- the next step for the self-review packet.

`journal.md`

- an append-only log of how the contribution packet was assembled and reassembled;
- doubts;
- forks;
- why some things were added or excluded;
- important user/manager quotes about evaluating contribution and metrics.

`logs/contributions.md`

- what the user did for others or for the system;
- whom it helped;
- which problem it removed;
- whether the contribution was `countable`, `intangible` or mixed;
- evidence links;
- why it matters.

`logs/received-help.md`

- who helped the user;
- with what exactly;
- how it affected the work;
- whether there is a follow-up or a reciprocity note.

`logs/unfinished.md`

- what was started but not finished;
- why it is still significant;
- why it was stopped;
- which materials already exist;
- when to return to it.

## 4. Entry format

By default use dated entries with a short structure:

```markdown
## DD.MM.YYYY

### {short title}

- Beneficiary:
- Type: `countable` | `intangible` | `mixed`
- Contribution:
- Problem solved / value created:
- Evidence:
- Notes:
```

For `received-help.md`:

```markdown
## DD.MM.YYYY

### {person}

- Help:
- Why it mattered:
- Evidence:
- Follow-up:
```

For `unfinished.md`:

```markdown
## DD.MM.YYYY

### {initiative}

- Problem / opportunity:
- Started:
- Not finished because:
- Why it still matters:
- Existing artifacts / evidence:
- Suggested next moment to revisit:
```

If the user already has a spreadsheet or their own format, do not break it without a reason:

- keep the original in `sources/`;
- on top of it make a structured summary and/or markdown replacement docs.

## 5. Tabular artifacts

For `xlsx/csv/ods`:

- keep the original as the source of truth;
- do not flatten the workbook into lossy plain text;
- record:
  - the list of sheets;
  - the meaning of each sheet;
  - the key columns;
  - the approximate size;
  - what is especially valuable in this table for self-review.

If there are explicit sheets such as:

- `whom I helped`;
- `who helped me`;
- `started but not finished`;

then preserve this semantics rather than collapsing everything into one flat sheet.

## 6. What not to do

- do not turn the contribution log into a brag document without context;
- do not remove help received, leaving only personal wins;
- do not discard unfinished work if it shows an important but hard-to-quantify contribution;
- do not substitute rhetoric for evidence;
- do not use this skill for a session debrief or an incident postmortem.

## 7. Relation to other skills

- `task` can create or find the container;
- `summary` can import a workbook/chat/log packet into `sources/` and `file-summaries/`;
- `doc-write` can turn the contribution packet into a clean self-review document;
- `lessons` can take durable patterns from contribution logs, but only if they genuinely recur;
- `research` can use such packets as material for topics about glue work, metrics and process visibility.
