# Claude And Codex Setup

This document describes the intended integration shape. The exact installer can evolve, but the boundary should stay stable.

## Recommended Directory Layout

```text
~/haretrail/       # reusable system repo
~/haretrail-data/  # private data repo
```

## Data Directory Contract

Tools that need real user data should use an explicit path:

```bash
export HARETRAIL_DATA_DIR="$HOME/haretrail-data"
```

The system repository should not hardcode personal data paths.

## Claude

Claude integrations should expose HARE Trail workflows as skills or slash-command wrappers.

Expected connector shape:

```text
~/.claude/skills/task -> ~/haretrail/integrations/claude/skills/task
~/.claude/skills/research -> ~/haretrail/integrations/claude/skills/research
```

Claude should read data-repo instructions when working with real notes:

```text
~/haretrail-data/AGENTS.md
~/haretrail-data/LESSONS.md
```

## Codex

Codex integrations should expose skills through the configured Codex skills directory and should read the active repository instructions from the data repo when editing real data.

Expected connector shape:

```text
~/.codex/skills/task -> ~/haretrail/skills/task
~/.codex/skills/research -> ~/haretrail/skills/research
```

## Permission Model

Agents often ask for permission when writing outside the current working directory. HARE Trail should reduce that friction by design:

- run daily private-note work from the data repo;
- run system development from the system repo;
- use a shared parent workspace when both repos must be edited together;
- keep sanitized fixtures in the system repo for tests and examples;
- use `HARETRAIL_DATA_DIR` only for explicit operations that need real data.
