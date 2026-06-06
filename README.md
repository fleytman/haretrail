# HARE Trail

**HARE Trail** is a **Human-Agent Reasoning Environment with Traceable Research Artifacts for Inquiry & Learning**.

It is a file-first work and research system for people working with AI agents. It preserves not only outputs, but the path behind them: sources, questions, hypotheses, attempts, evidence, corrections, debriefs, lessons and reusable workflows.

The first goal is human work: readable notes, recoverable reasoning, explicit evidence and less repeated error. Feeding useful context back to AI agents is a second-order benefit, not the reason the system exists.

## What Problem It Solves

AI-assisted work often leaves important context trapped in chats, terminal scrollback, local scratch files and untracked notes. A later session can sound confident while missing the actual path: what was asked, what changed, what was checked, what failed and what the user corrected.

HARE Trail makes that path inspectable.

It is designed to reduce:

- overtrust in fluent AI answers;
- confirmation bias in human-agent work;
- cross-session and cross-repository context loss;
- persuasive summaries that hide missing verification;
- repeated mistakes that never become lessons;
- private working notes becoming unrecoverable clutter.

## Current Repository Role

This repository is the reusable **system layer**.

Current maturity: this repository is a documentation-first system scaffold. It explains the reusable workflow contracts and contains migration target directories, but it does not yet ship installable skills, connector scripts or reusable templates.

The target system layer will contain:

- workflow and command contracts;
- skills and integration wrappers;
- templates;
- setup documentation for Claude and Codex;
- public philosophy and use-case docs;
- sanitized examples and fixtures.

It should not contain:

- private notes;
- real work artifacts;
- real session debriefs;
- private lessons;
- exported private chats;
- company-specific project history;
- local absolute paths.

Real work belongs in a separate data repository.

Available now:

- system/data boundary rules;
- public philosophy, goals and use-case documentation;
- command contracts;
- Claude/Codex setup contract;
- analogs comparison;
- empty migration target directories for skills, integrations, templates, scripts and examples.

Not available yet:

- installable Claude or Codex skills;
- connector install scripts;
- reusable templates;
- sanitized example datasets;
- clean-checkout setup validation.

## Recommended Layout

```text
haretrail/       # reusable system repository
haretrail-data/  # private notes, work artifacts, debriefs and lessons
```

Daily work with real artifacts should usually run from the data repository. System development, reusable templates, skill work and documentation belong here.

## Main Concepts

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

## Commands

The core workflows are:

- `task`
- `summary`
- `research`
- `doc-write`
- `debrief`
- `lessons`
- `postmortem`
- `contribution-log`

See [Commands](docs/commands.md).

## Documentation

- [Philosophy](docs/philosophy.md)
- [Goals and Use Cases](docs/goals-and-use-cases.md)
- [Commands](docs/commands.md)
- [Claude and Codex Setup](docs/setup-claude-codex.md)
- [Analogs Comparison](docs/compare-analogs.md)
- [Status and Roadmap](docs/status-and-roadmap.md)

## Current Status

Phase 1 is complete: the system/data boundary and repository name are frozen.

Phase 2 is complete: the public docs now describe the reusable system without depending on the private research corpus.

Phase 3 is not complete: `skills/`, `integrations/`, `templates/` and `scripts/` are present as migration targets, but the real reusable assets still need to be moved and cleaned.

## Design Rule

If a file cannot be published without exposing private work, personal history, company context or local paths, it does not belong in this repository. Extract the reusable rule, template or workflow instead.
