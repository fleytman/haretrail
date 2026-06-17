# Kiro Integration

HARE Trail supports two Kiro surfaces: **Kiro CLI** (terminal agent) and **Kiro IDE** (VS Code extension). They use different loading mechanisms and require different connector types.

---

## Kiro CLI

Kiro CLI loads skills and context through agent configuration. It does not auto-scan a skills directory the way the Codex-style connectors assume, so the HARE Trail connector for Kiro CLI is a generated agent config, not a skills symlink.

### Generated Agent

`scripts/install-connectors.sh --include-kiro-cli --data-dir <data-repo>` writes:

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

### Why An Agent And Not Steering (CLI)

A custom agent gives progressive disclosure: skills are loaded on demand via `skill://`, so the context window is not filled by every workflow on every turn. A global steering file is always in context for the built-in default agent, which is more intrusive and more expensive in tokens.

### Install, Validate, Run (CLI)

```bash
./scripts/install-connectors.sh --dry-run --include-kiro-cli --data-dir /path/to/haretrail-data
./scripts/install-connectors.sh --include-kiro-cli --write-config --data-dir /path/to/haretrail-data
kiro-cli agent validate --path ~/.kiro/agents/haretrail.json
kiro-cli chat --agent haretrail
```

`--include-kiro` is a backward-compatible alias for `--include-kiro-cli`.

---

## Kiro IDE

Kiro IDE (VS Code extension) uses a different loading model from the CLI. Three particularities are essential to get the connector working:

1. **Skills are folders, not files.** A user-level skill must live at `~/.kiro/skills/<name>/SKILL.md` (a directory with a `SKILL.md` inside), with frontmatter `name` + `description`. A flat `~/.kiro/skills/<name>.md` file is silently ignored.
2. **Activation is via `/`, not `#`.** Skills and `inclusion: manual` steering show up as slash commands (e.g. `/haretrail-task`). The `#` menu is workspace file search and does not list user-level skills/steering.
3. **The agent is sandboxed to the open workspace** (plus `~/.kiro/`). It cannot read files in an external folder until that folder is part of the open workspace. See "Data Repo Access" below.

Steering files (`~/.kiro/steering/*.md`) with `inclusion: auto` + `description` are loaded into context on every turn. Kiro IDE does **not** read `~/.kiro/agents/*.json` (that is CLI-only). Symlinks under `~/.kiro/skills` and `~/.kiro/steering` are currently unreliable (upstream issues), so the connector generates real files instead of linking.

### Generated Files

`scripts/install-connectors.sh --include-kiro-ide --data-dir <data-repo>` writes:

```text
~/.kiro/steering/haretrail.md           (always in context — paths, core rules, skill dispatch table)
~/.kiro/skills/haretrail-<skill>/SKILL.md (thin wrappers pointing to canonical sources)
~/.haretrail/haretrail.code-workspace   (multi-root workspace: data repo + system repo)
```

### Data Repo Access (IDE)

The Kiro IDE agent is sandboxed to the folders of the **open workspace**. The data repo lives outside the system repo by design (system/data boundary), so opening only the system repo leaves `{data-repo}` unreachable and HARE Trail workflows cannot write artifacts.

To close this gap the installer generates a multi-root workspace file under the local config dir (never inside the system or data repo):

```text
~/.haretrail/haretrail.code-workspace
```

Open it via **File > Open Workspace from File...** (or `code ~/.haretrail/haretrail.code-workspace`). It lists both the data repo and the system repo as roots, so the agent can read canonical skills from the system repo and write artifacts into the data repo in one session.

### How It Works (IDE)

The steering file is a compact always-loaded context that tells the agent:
- where the system repo and data repo are;
- the core HARE Trail rules (progressive disclosure, data boundary, language);
- a **skill dispatch table**: when the user asks for a specific workflow, the agent reads the corresponding canonical SKILL.md and workflow.md from the system repo before acting.

This gives a single-file integration that works across all workspaces without per-project setup. The tradeoff is that the dispatch table is always in context (~30 lines), but it is small enough to be acceptable.

### Install (IDE)

```bash
./scripts/install-connectors.sh --dry-run --include-kiro-ide --data-dir /path/to/haretrail-data
./scripts/install-connectors.sh --include-kiro-ide --write-config --data-dir /path/to/haretrail-data
```

For a fully hands-off setup, add `--open-workspace` to also open the generated multi-root workspace in Kiro IDE via the `kiro` CLI:

```bash
./scripts/install-connectors.sh --include-kiro-ide --open-workspace --write-config --data-dir /path/to/haretrail-data
```

After installation, reload Kiro IDE (or open the generated workspace) to pick up the steering file and skills.

### Usage In IDE

The steering file loads automatically on every turn. When you ask for a HARE Trail workflow (e.g. "создай дебриф", "начни задачу"), the agent will:
1. Match the request to the skill dispatch table.
2. Read the canonical SKILL.md and references/workflow.md.
3. Act according to the workflow contract.

---

## Safety

- The installer writes only under the Kiro home (and `~/.haretrail/config.env` with `--write-config`). It does not write into the data repo and does not copy private data.
- Generated files are self-identified by `generated-by=haretrail-install-connectors` as an HTML comment or JSON description field. A re-run overwrites HARE Trail files in place but backs up any foreign file to `*.bak.<timestamp>` first.
- No private absolute paths are stored in this repository. Concrete paths appear only in the generated local files.

## Validation Status

- **Steering + skill loading (IDE): confirmed.** A live Kiro IDE session loads `~/.kiro/steering/haretrail.md` automatically and activates folder-form skills (e.g. `haretrail-task`) on demand. This was verified by inspecting the loaded skill content in a running session.
- **Multi-root data-repo write flow: not yet validated end-to-end.** Generating the workspace and opening it is implemented, but a clean fresh-session run that creates an artifact in the data repo through the IDE agent has not been recorded yet.
- **Kiro CLI and Claude/Codex connectors:** runtime loading gaps tracked separately.
