# Commands

HARE Trail commands are workflow contracts. They can be exposed as skills, slash commands, scripts or agent instructions depending on the host tool.

Current maturity: reusable skill source folders are present under `skills/`, but connector installation and clean-checkout validation are not done yet.

## Command Overview

| Command | Use When | Main Output | Writes To |
| --- | --- | --- | --- |
| `task` | Work should survive a session, model switch or repo switch. | Task folder with README, tracker and journal. | Data repo `work-artifacts/` |
| `summary` | A packet of files, docs, exports or sources needs structured summary. | Sources, file summaries, quotes, optional prompts. | Data repo task folder |
| `research` | A question needs hypotheses, checks, sources and evolving interpretation. | Research tracker, journal, source packet and summaries. | Data repo task folder |
| `doc-write` | Documentation must be written or updated. | Human-readable docs following target repo rules. | Target repo or data repo |
| `debrief` | A session produced mistakes, false hypotheses, corrections or lessons. | Session debrief and updated lessons index. | Data repo `session-debriefs/`, `LESSONS.md` |
| `lessons` | Lessons must be read, added or refined without a full debrief. | Distilled lesson updates. | Data repo `LESSONS.md` |
| `postmortem` | Incident-grade analysis is needed. | Timeline, impact, root cause, corrective actions, lessons. | Data repo `postmortems/` |
| `contribution-log` | Invisible work, glue work or self-review evidence must be recorded. | Contribution log or visibility artifact. | Data repo task folder or notes |

## `task`

Use when the user wants to start, find or continue a durable task folder.

Minimum output:

```text
README.md
tracker.md
journal.md
```

Optional output:

```text
sources/
file-summaries/
prompts/
pr/
verification/
architecture/
migration-log.md
```

Rules:

- use an existing task folder when it clearly matches;
- create a new one when the work needs persistence;
- do not create prompt artifacts unless requested;
- preserve source dates and import dates separately during migrations.

## `summary`

Use for document packets: markdown, PDFs, exports, chats, spreadsheets, logs or large prompts.

Expected work:

- import meaningful sources;
- preserve originals when useful;
- summarize per file or per packet;
- extract important quotes when useful;
- identify conversion gaps;
- create prompts only on explicit request.

## `research`

Use when the question itself evolves.

Expected work:

- record current question;
- state hypotheses and constraints;
- track evidence and contradictions;
- keep a journal of attempts and interpretation;
- preserve source packets;
- identify next research branches.

## `doc-write`

Use when producing documentation for a repository or project.

Rules:

- read the target repo's local rules first;
- follow existing style and language;
- distinguish canonical repo docs from private work artifacts;
- do not turn a migration into a marketing essay.

## `debrief`

Use for session-level learning.

Capture:

- mistakes by participant;
- false hypotheses;
- user corrections;
- what actually worked;
- lessons for future sessions.

The output should be honest and actor-labeled. It should not blur the user, agent and other tools into one vague narrator.

## `lessons`

Use for distilled patterns without a full debrief.

Rules:

- add only lessons supported by evidence;
- avoid duplicates;
- keep lessons concise and future-facing;
- link back to debriefs when possible.

## `postmortem`

Use for serious incidents, not ordinary session notes.

Typical sections:

- summary;
- impact;
- timeline;
- root cause;
- contributing factors;
- corrective actions;
- lessons learned.

## `contribution-log`

Use when work matters but may be invisible:

- review support;
- debugging support;
- coordination;
- mentoring;
- glue work;
- self-review evidence;
- started-but-not-finished work with real value.

## Global Command Rules

- Keep reusable workflow logic in the system repo.
- Keep real personal data in the data repo.
- Prefer source-bound claims over memory-based summaries.
- Do not silently add backward compatibility for renamed commands.
- Do not suppress conversion or parsing quality problems.
- Do not treat a fluent answer as verification.
