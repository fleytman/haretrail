# Claude And Codex Setup

This document describes the intended two-repository setup.

Current maturity: `scripts/install-connectors.sh` can install source skill symlinks for Codex and agents directories, and `scripts/init-data-repo.sh` can create a minimal private data repo scaffold. Claude source links are available behind an explicit flag, but tool-specific Claude wrappers and actual Claude/Codex runtime loading are not complete yet.

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

User-local HARE Trail configuration is expected to live outside the public repo, for example under `~/.haretrail/`. Project-local ignored config may be added later for HARE Trail routing, but it must not override the target repository's own coding or documentation rules.

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

Current optional source-link shape:

```text
~/.claude/skills/task -> haretrail/skills/task
~/.claude/skills/research -> haretrail/skills/research
```

Target wrapper shape:

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

Current connector shape:

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

## Installer

Dry run first:

```bash
./scripts/install-connectors.sh --dry-run --data-dir examples/fixture-data-repo
```

Install Codex and agents skill links:

```bash
./scripts/install-connectors.sh --data-dir /path/to/haretrail-data
```

Optionally install Claude source links:

```bash
./scripts/install-connectors.sh --include-claude --data-dir /path/to/haretrail-data
```

## Data Repo Initialization

Dry run first:

```bash
./scripts/init-data-repo.sh --dry-run --target /tmp/haretrail-data-demo
```

Create a private data repo scaffold:

```bash
./scripts/init-data-repo.sh --target /path/to/haretrail-data
```

Create a private data repo scaffold plus an initial research folder:

```bash
./scripts/init-data-repo.sh \
  --target /path/to/haretrail-data \
  --initial-task first-research-thread \
  --task-title "First research thread" \
  --task-kind research
```

The initializer writes missing files only. It creates README, tracker, journal, lessons and core data directories, but it does not copy private corpus and does not write into home-directory tool configs.

## Remaining Phase 3 Work

Before calling setup complete:

- add Claude wrappers;
- prove actual Claude/Codex runtime loading;
- add Docker/container or equivalent fixture smoke;
- verify no private paths are embedded in generated connectors or initialized data scaffolds.
