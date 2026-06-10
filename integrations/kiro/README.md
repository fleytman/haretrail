# Kiro CLI Integration

Kiro CLI loads skills and context through agent configuration. It does not auto-scan a skills directory the way the Codex-style connectors assume, so the HARE Trail connector for Kiro is a generated agent config, not a skills symlink.

## Generated Agent

`scripts/install-connectors.sh --include-kiro --data-dir <data-repo>` writes:

```text
~/.kiro/agents/haretrail.json
```

Use `--kiro-home` to target a different Kiro home (useful for tests).

The agent config contains:

- `prompt`: a HARE Trail working prompt with the concrete system-repo and data-repo paths baked in, instructing the agent to read the behavior contract and the relevant skill before acting, to follow progressive disclosure, and to keep private artifacts in the data repo;
- `resources`:
  - `skill://<system-repo>/skills/<skill>/SKILL.md` for each of the eight workflow skills — metadata is loaded at startup and full content on demand;
  - `file://<system-repo>/skills/_shared/system-behavior.md` — the reusable behavior contract, always in context;
  - `file://<data-repo>/AGENTS.md` and `file://<data-repo>/BASE.md` when present — local rules and paths;
- `tools`: `read`, `write`, `shell`, `grep`, `glob`, `code`;
- `allowedTools`: `read`, `grep`, `glob` — writes and shell commands prompt for approval.

`LESSONS.md` is intentionally not force-loaded into context. It can be large, so it is read on demand through the `lessons` skill.

## Why An Agent And Not Steering

A custom agent gives progressive disclosure: skills are loaded on demand via `skill://`, so the context window is not filled by every workflow on every turn. A global steering file is always in context for the built-in default agent, which is more intrusive and more expensive in tokens.

A steering file remains a valid optional alternative when you want the default agent to always know about HARE Trail without switching agents:

```text
~/.kiro/steering/haretrail.md
```

Keep it small. The installer does not generate it by default.

## Install, Validate, Run

```bash
./scripts/install-connectors.sh --dry-run --include-kiro --data-dir /path/to/haretrail-data
./scripts/install-connectors.sh --include-kiro --write-config --data-dir /path/to/haretrail-data
kiro-cli agent validate --path ~/.kiro/agents/haretrail.json
kiro-cli chat --agent haretrail
```

## Safety

- The installer writes only under the Kiro home (and `~/.haretrail/config.env` with `--write-config`). It does not write into the data repo and does not copy private data.
- The generated file is self-identified by `generated-by=haretrail-install-connectors` in its `description`. A re-run overwrites a HARE Trail agent in place but backs up any foreign `haretrail.json` to `haretrail.json.bak.<timestamp>` first.
- No private absolute paths are stored in this repository. Concrete paths appear only in the generated local `~/.kiro/agents/haretrail.json`.

## Not Yet Validated

Actual runtime loading of the skills by a live Kiro session has not been validated from a fresh session yet. This is the same open gap as the Claude and Codex connectors in this repository.
