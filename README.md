# HARE Trail

**HARE Trail** is a Human-Agent Reasoning Environment with Traceable Research Artifacts for Inquiry & Learning.

It is a file-first system for preserving the path of work: questions, sources, decisions, evidence, corrections, debriefs and lessons. The primary user is a human working with AI agents; agent-readable memory is important, but it is not the first goal.

## Why It Exists

AI work often loses the path that led to an answer. HARE Trail keeps that path recoverable so a person can revisit what was asked, what changed, what was checked, what failed, and what should be learned.

The system is designed to reduce repeated mistakes such as:

- overtrusting confident AI output;
- confirmation bias in human-agent work;
- losing context between sessions, tools and repositories;
- confusing persuasive narrative with verified evidence;
- letting private scratch work become unstructured and unrecoverable.

## Repository Scope

This repository contains the reusable system layer:

- workflows and skills;
- templates;
- integration docs for Claude and Codex;
- philosophy, use cases and command contracts;
- examples and fixtures that do not contain personal data.

This repository must not contain personal notes, real work artifacts, session debriefs, lessons, private exports or raw research packets. Those belong in a separate data repository.

## Current Docs

- [Philosophy](docs/philosophy.md)
- [Goals and Use Cases](docs/goals-and-use-cases.md)
- [Commands](docs/commands.md)
- [Claude and Codex Setup](docs/setup-claude-codex.md)
- [Analogs Comparison](docs/compare-analogs.md)

## Recommended Layout

```text
~/haretrail/              # reusable system repository
~/haretrail-data/         # private data repository
```

For daily work, run agents from the data repository when editing real notes and artifacts. Use this repository for reusable workflows, templates, examples and integration code.
