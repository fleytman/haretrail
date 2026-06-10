# Claude And Codex Setup

This document describes the intended two-repository setup.

Current maturity: `scripts/install-connectors.sh` can install source skill symlinks or generated thin wrappers for Codex, optional agents directories and optional Claude skills. `scripts/init-data-repo.sh` can create a minimal private data repo scaffold. Actual Claude/Codex runtime loading still needs fresh-session validation.

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

The connector installer can write this local file:

```text
~/.haretrail/config.env
```

Example content:

```bash
HARETRAIL_SYSTEM_DIR=/path/to/haretrail
HARETRAIL_DATA_DIR=/path/to/haretrail-data
```

This file is local machine configuration. Do not commit it to the system repo.

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

Optional source-link shape:

```text
~/.claude/skills/task -> haretrail/skills/task
~/.claude/skills/research -> haretrail/skills/research
```

Generated wrapper shape:

```text
~/.claude/skills/task/SKILL.md
~/.claude/skills/research/SKILL.md
```

The wrapper is intentionally small. It points Claude to the canonical source skill in `haretrail/skills/<skill>/SKILL.md` and gives the concrete local data repo path from installer config.

When working with real notes, Claude should read the data repo instructions and lessons, not private corpus from the system repo.

Expected data-side files:

```text
haretrail-data/AGENTS.md
haretrail-data/LESSONS.md
```

## Codex

Codex integrations should expose skills through the configured Codex skills directory.

Source-link connector shape:

```text
~/.codex/skills/task -> haretrail/skills/task
~/.codex/skills/research -> haretrail/skills/research
```

Generated wrapper shape:

```text
~/.codex/skills/task/SKILL.md
~/.codex/skills/research/SKILL.md
```

When editing real data, start Codex in the data repo when practical. This keeps writes inside the active workspace and avoids unnecessary permission prompts.

## Kiro CLI

Kiro CLI does not auto-scan a skills directory. It loads skills and context through agent configuration, so the HARE Trail connector for Kiro is a generated agent config rather than a skills symlink.

Generated shape:

```text
~/.kiro/agents/haretrail.json
```

The agent references the canonical source skills and the data repo:

- `skill://<system-repo>/skills/<skill>/SKILL.md` for each workflow skill (metadata at startup, full content on demand);
- `file://<system-repo>/skills/_shared/system-behavior.md` for the reusable behavior contract;
- `file://<data-repo>/AGENTS.md` and `file://<data-repo>/BASE.md` for local rules.

`LESSONS.md` is intentionally not force-loaded; it is read on demand through the `lessons` skill.

Install it:

```bash
./scripts/install-connectors.sh \
  --include-kiro \
  --write-config \
  --data-dir /path/to/haretrail-data
```

Validate and run:

```bash
kiro-cli agent validate --path ~/.kiro/agents/haretrail.json
kiro-cli chat --agent haretrail
```

The generated agent file is self-identified by a marker in its `description`. A re-run overwrites a HARE Trail agent in place but backs up any foreign `haretrail.json` first.

An optional alternative is a global steering file at `~/.kiro/steering/haretrail.md`, which the built-in default agent loads automatically. Steering content is always in context, so keep it small. See `integrations/kiro/README.md`.

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

Install Codex source links:

```bash
./scripts/install-connectors.sh --data-dir /path/to/haretrail-data
```

Install generated thin wrappers plus local config:

```bash
./scripts/install-connectors.sh \
  --mode wrapper \
  --write-config \
  --data-dir /path/to/haretrail-data
```

Optionally include Claude wrappers:

```bash
./scripts/install-connectors.sh \
  --mode wrapper \
  --write-config \
  --include-claude \
  --data-dir /path/to/haretrail-data
```

Optionally generate the Kiro CLI agent config:

```bash
./scripts/install-connectors.sh \
  --include-kiro \
  --write-config \
  --data-dir /path/to/haretrail-data
```

Optionally include agents wrappers only when the target tool requires `~/.agents/skills` and does not also scan `~/.codex/skills`:

```bash
./scripts/install-connectors.sh \
  --mode wrapper \
  --write-config \
  --include-agents \
  --data-dir /path/to/haretrail-data
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

By default, the scaffold `.gitignore` keeps `work-artifacts/*` out of the parent data repo. Significant task/research folders should use their own local git repositories until the data versioning policy is proven in real use.


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

- prove actual Claude/Codex runtime loading;
- add Docker/container or equivalent fixture smoke;
- verify no private paths are embedded in generated connectors or initialized data scaffolds.
