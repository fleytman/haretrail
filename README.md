# HARE Trail

**HARE Trail** — a **Human-Agent Reasoning Environment with Traceable Research Artifacts for Inquiry & Learning**.

A file-first work and research system for people working with AI agents. You work as usual; the system keeps the *path* behind your work — questions, sources, attempts, evidence, corrections, debriefs, lessons — as readable Markdown files that both you and your AI can reopen later.

## The pain

AI-assisted work leaves important context trapped in chats, terminal scrollback and throwaway notes. Later — next week, next session, next tool — that context is gone:

- you come back to a task and spend half an hour rebuilding "where was I, what did we try, what failed";
- you switch from your IDE agent to a web chat and the new session knows nothing about the old one;
- a confident summary hides that nothing was actually verified;
- the same mistake gets made again because the last fix never became a lesson;
- six months later you can't reconstruct what you did for a self-review.

## How HARE Trail addresses it

You keep a **reopenable trail**: what was asked, what was checked, what failed — so the next session and the next person don't restart from zero. Concretely:

- **The journal writes the path of work; your AI reads it back.** You don't hand-write documentation — the workflow records sources, attempts, evidence and corrections as you go, and a later agent can grep it instead of you re-explaining.
- **One memory across tools and sessions.** The trail lives in files, not inside one chat — so an IDE agent in the morning and a phone chat in the evening share the same context.
- **Evidence over fluent answers.** Verification artifacts record *what was actually checked*, so a plausible-sounding summary can't quietly stand in for a real check.
- **Mistakes become lessons.** Debriefs capture false hypotheses and corrections; lessons are meant to keep the same error from repeating.

It is built to push back on overtrust in fluent AI answers, on confirmation bias in human-agent work, and on cross-session / cross-repository context loss. The first goal is **human** reasoning; feeding context back to AI agents is a second-order benefit.

## What you get — small examples

Each example: the pain, the action (your effort ≈ 0 — you work as usual), and what you save.

**1. Coming back to a task after a break.**
- *Without:* 40 minutes re-reading Slack, recalling where you stopped, re-feeding context to the agent.
- *With:* one command pulls the task's trail — "you stopped here; the last attempt failed because X; next step was Y" — in seconds.

**2. Cross-agent memory (something a single chat's `resume` cannot do).**
- *Without:* the work you did in your IDE agent is invisible to tonight's web-chat session.
- *With:* point the evening session at the day's trail file → it continues with full context. Different tools, different sessions, one memory.

**3. Finding the cause of a bug from your own past notes.**
- *Without:* you half-remember hitting this two months ago, but the reasoning is gone.
- *With:* grep your own debriefs/journal for the symptom → the earlier investigation and its resolution are right there.

> These are illustrative use cases, not benchmarked claims — time figures are typical, not measured. The honest promise is "what commands you run and what artifact you get back", not "faster than a plain chat".

## Walkthrough: read a filled trail

The fastest way to understand the shape is to read a real, filled-in trail rather than a description:

- **Public worked example:** [`fleytman/thaw-problems`](https://github.com/fleytman/thaw-problems) — a real research task carried through the system (overview docs, journal, tracker, analysis, evidence, drafts), with English and Russian versions.
- **Bundled fixture:** [`examples/fixture-data-repo/`](examples/fixture-data-repo/) — a small fictional data repo showing the artifact shapes (journal with Question/Attempt/Evidence/Result/Interpretation, tracker, file-summaries, verification, sources, a session debrief).

## Install and start

Two repositories: this reusable **system** repo, and a private **data** repo for your real notes.

```text
haretrail/       # reusable system repository (this repo)
haretrail-data/  # your private notes, work artifacts, debriefs and lessons
```

```bash
# 1. Create a private data repo scaffold (dry-run first to preview)
./scripts/init-data-repo.sh --dry-run --target /path/to/haretrail-data
./scripts/init-data-repo.sh --target /path/to/haretrail-data

# 2. Connect the skills to your agent (Claude / Codex / agents dir)
./scripts/install-connectors.sh --dry-run --data-dir /path/to/haretrail-data
./scripts/install-connectors.sh --data-dir /path/to/haretrail-data
```

See [Claude and Codex Setup](docs/setup-claude-codex.md) for connector modes and per-tool details.

> First-time setup is still experimental — a clean-checkout install has not been fully validated end to end yet. See **Status** below for what is and isn't proven.

## How to use it

Commands are workflow contracts, exposed as skills / slash-commands depending on your host tool. Typical loop:

1. `task` — start or continue a task folder for the thing you're working on.
2. `research` / `summary` — pull in sources, summarize, build a plan, keep tracker + journal as you go.
3. `verification` artifacts — record what you actually checked.
4. `debrief` — at the end of a session, capture mistakes, false hypotheses and lessons.
5. `lessons` / `postmortem` / `contribution-log` — distil reusable lessons, heavy incident analysis, or contribution/self-review evidence.

Core workflows: `task`, `summary`, `research`, `doc-write`, `debrief`, `lessons`, `postmortem`, `contribution-log`. Full contracts: [Commands](docs/commands.md). More examples will live in a dedicated examples doc.

## Main concepts

| Concept | Meaning |
| --- | --- |
| Task folder | A durable folder for one task, question, investigation or project thread. |
| Source packet | Imported docs, chat exports, logs, prompts or files used as raw material. |
| Tracker | Current state, decisions, open questions and next actions. |
| Journal | Append-only path of thought, attempts, corrections and interpretation. |
| Verification artifact | Evidence for claims: commands, logs, smoke matrices, reproductions, screenshots or reviews. |
| Debrief | Session-level analysis of mistakes, false hypotheses, corrections and lessons. |
| Lessons | Distilled patterns meant to improve future work. |
| Postmortem | Heavier incident-grade analysis for serious failures. |

## Documentation

- [Philosophy](docs/philosophy.md)
- [Goals and Use Cases](docs/goals-and-use-cases.md)
- [System Behavior](docs/system-behavior.md)
- [Commands](docs/commands.md)
- [Claude and Codex Setup](docs/setup-claude-codex.md)
- [Analogs Comparison](docs/compare-analogs.md)
- [Status and Roadmap](docs/status-and-roadmap.md)

## Status

This is an early public release of the reusable **system layer**. Phase 1 (system/data boundary and name) and Phase 2 (public docs independent of the private corpus) are complete. Phase 3 is in progress: reusable skill sources, templates, a sanitized fixture data repo, a source-link/thin-wrapper connector installer and a data repo initializer are present.

A clean-checkout install has not been fully tested end to end, so treat first-time setup as experimental. The following are intentionally **not done yet** — they are the first steps after this release, not blockers before it:

- validate a clean-checkout install path from scratch;
- prove Claude/Codex runtime loading from fresh sessions;
- add Docker/container smoke validation;
- run at least one fixture-only workflow smoke;
- confirm duplicate skill discovery behavior for Codex and Claude.

The data repository (your real notes, work artifacts, debriefs, lessons) is separate and private — see the [Design Rule](#design-rule).

## Design rule

If a file cannot be published without exposing private work, personal history, company context or local paths, it does not belong in this repository. Extract the reusable rule, template or workflow instead.

## License

HARE Trail is source-available, **not** OSI open source.

It is licensed under the **Functional Source License, Version 1.1, MIT Future License (FSL-1.1-MIT)** — see [LICENSE](LICENSE). In short:

- internal use, noncommercial education and noncommercial research are broadly permitted;
- a **Competing Use** — a commercial product or service that substitutes for or offers substantially similar functionality to HARE Trail — is **not** permitted;
- each version **converts to the MIT license two years after its release**.

Please credit the project when you use or build on it — see [NOTICE](NOTICE) for the requested attribution (author, repository link and contact). Commercial use beyond the license requires a separate agreement (contact m.fleytman@gmail.com).

## Contributing

Contributions are welcome. By contributing you agree to the [Contributor License Agreement](CLA.md), which lets the project keep its licensing consistent and offer commercial licenses. To sign, comment on your pull request:

> I have read the CLA Document and I hereby sign the CLA
