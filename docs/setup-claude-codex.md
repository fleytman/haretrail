# Claude And Codex Setup

This document describes the intended two-repository setup.

Current maturity: this is a setup contract, not a working installer guide. The connector paths below describe the target shape for Phase 3; they are not shipped by this repository yet.

## Recommended Layout

```text
haretrail-workspace/
  haretrail/       # reusable system repo
  haretrail-data/  # private data repo
```

The exact parent directory is not important. Keeping both repositories under one parent can reduce permission friction when agents need to edit both.

## Data Directory Contract

Tools that need real user data should use an explicit path:

```bash
export HARETRAIL_DATA_DIR="/path/to/haretrail-data"
```

The system repo should not hardcode personal paths.

## What Belongs Where

System repo:

- skills;
- templates;
- integration wrappers;
- scripts;
- public docs;
- sanitized examples.

Data repo:

- work artifacts;
- notes;
- session debriefs;
- lessons;
- postmortems;
- imported sources;
- personal or project overlays.

## Claude

Claude integrations should expose HARE Trail workflows as skills or slash-command wrappers.

Target connector shape:

```text
~/.claude/skills/task -> haretrail/integrations/claude/skills/task
~/.claude/skills/research -> haretrail/integrations/claude/skills/research
```

When working with real notes, Claude should read the data repo instructions and lessons, not the private corpus from the system repo.

Expected data-side files:

```text
haretrail-data/AGENTS.md
haretrail-data/LESSONS.md
```

## Codex

Codex integrations should expose skills through the configured Codex skills directory.

Target connector shape:

```text
~/.codex/skills/task -> haretrail/skills/task
~/.codex/skills/research -> haretrail/skills/research
```

When editing real data, start Codex in the data repo when practical. This keeps writes inside the active workspace and avoids unnecessary permission prompts.

## Permission Model

Agents often need permission to write outside the current working directory. HARE Trail should reduce that friction by design:

- run private artifact work from the data repo;
- run system development from the system repo;
- use a shared parent workspace when both repos must be edited;
- use `HARETRAIL_DATA_DIR` for explicit data access;
- keep sanitized fixtures in the system repo for tests and examples.

## Phase 3 Work

The connector scripts and wrappers are not migrated yet.

Before calling setup complete:

- migrate the reusable skills;
- add Claude wrappers;
- add Codex-compatible skill layout;
- add an install script;
- validate setup from a clean checkout;
- verify no private paths are embedded in generated connectors.
