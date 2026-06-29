# Commands

HARE Trail commands are workflow contracts. They can be exposed as skills, slash commands, scripts or agent instructions depending on the host tool.

Current maturity: reusable skill source folders are present under `skills/`, source-link connector installation has been validated from a clean local checkout, and `scripts/init-data-repo.sh` can create a minimal private data scaffold. Actual Claude/Codex runtime loading is not fully validated yet.

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
| `work-evidence` | Evidence of your own work over a period must be gathered from sources. | Normalized, source-bound work ledger (engine for `daily`/`contribution-log`). | Consumer's `sources/` |
| `daily` | A work standup is needed ("what I did from X to Y"). | 4-section standup: progress, invisible work, insights, blockers. | Data repo `daily/YYYY-MM-DD/` |
| `retro` | A reflective retrospective over a period is needed (sprint / 2 weeks / before a demo). | Retro: wins, disappointments, resolved-vs-open, open questions, thanks owed, team pains. | Data repo `retro/YYYY-MM-DD/` |

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

## `work-evidence`

Shared engine. Gathers and normalizes evidence of your own work over a period from configured
sources (tracker, chat, code host, work notes and debriefs). Does not render a human-facing report —
it produces a source-bound ledger consumed by `daily` and `contribution-log`.

Rules:

- read sources, filters and language from `~/.haretrail/`; do not hardcode defaults;
- distinguish involvement type (created / merged / committed / reviewed / commented / pending) and key
  each by the time of the action, not by object creation date;
- record WHO did WHAT; "who clicked the button" is not "whose decision";
- status comes from the source system, not from narrative; dedup across sources;
- keep only work (filter personal); save raw per-source output under the consumer's `sources/`.

## `daily`

Thin consumer of `work-evidence`. Builds a work standup for a short period ("since the last daily")
and renders it into four sections.

Output sections:

1. progress on tasks (grouped by ticket; status and who moved it);
2. activities outside tasks (invisible work: help to colleagues, coordination, reviews of others' PRs);
3. insights / problems / questions (including lessons from `LESSONS.md` and debriefs in the period);
4. blockers.

Rules:

- cadence, sources and language from `~/.haretrail/`; ask and save on first run;
- explicit attribution (who did what); report tone (a lead may read it) — neutral, no slang;
- write a per-daily folder (`daily/YYYY-MM-DD/standup.md` + `sources/`); `daily/` is a local git repo;
- share via a separate export, not the repo; roll up into `contribution-log` for long periods.

## `retro`

Reflective retrospective over a period (sprint / 2 weeks / before a demo). Thin consumer of
`work-evidence`, but with a different, interactive and social mechanism.

Sources (dailies-first):

1. **Dailies** (`{data-repo}/daily/*/standup.md`) — primary: roll up insights/blockers/progress and
   **check resolution status** (resolved / still hurting); ask the user when unclear.
2. **DMs** — complaints and problems you raised, open questions (yours unanswered and unanswered to you),
   help received → who to thank / what you owe.
3. **Chat list (from config)** — problems raised, especially threads you participated in; optional
   separate agent for general problem discovery ("team pains").

Output sections: wins; disappointments/still-hurting; resolved-vs-open; open questions; thanks owed;
team pains; action items.

Rules:

- dailies-first + two-tier + schedule (fast roll-up of existing dailies; live Slack/source run is
  optional enrichment in the background);
- reflective and interactive (may ask "resolved? still hurting?"); explicit attribution; report tone;
- feeds `contribution-log` (help/thanks, invisible work) — do not duplicate it.

## Global Command Rules

- Keep reusable workflow logic in the system repo.
- Keep real personal data in the data repo.
- Prefer source-bound claims over memory-based summaries.
- Do not silently add backward compatibility for renamed commands.
- Do not suppress conversion or parsing quality problems.
- Do not treat a fluent answer as verification.
