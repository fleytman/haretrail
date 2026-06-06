# Analogs Comparison

This is a compact public comparison. It is not a full research log.

## Feature Matrix

| System | Human-readable source of truth | Agent runtime memory | Task/research folders | Debrief/lessons loop | Source/provenance discipline | Main gap relative to HARE Trail |
| --- | --- | --- | --- | --- | --- | --- |
| HARE Trail | Yes | Planned layer | Yes | Yes | Core design goal | Connectors, templates and clean-checkout setup still being migrated |
| Claude Code Memory | Partial | Yes | Partial | Limited | Project memory oriented | Less explicit about research trails, debriefs and private work artifacts |
| Claude Memory Bank | Yes | Partial | Yes | Limited | File-based | Less focused on anti-error loops and source packets |
| `claude-memory-skill` | Yes | Partial | Limited | Limited | Basic | Narrower than a full work/research system |
| `agentmemory` | Partial | Yes | Limited | Partial | Strong citation/provenance features | Runtime-memory first, less human-facing as a work dossier |
| ReasoningBank | No | Yes | No | Automated success/failure extraction | Benchmark/evaluation oriented | Research framework, not a human work system |
| Agent Workflow Memory | No | Yes | No | Workflow utility oriented | Benchmark/evaluation oriented | Workflow induction, not broad note/work artifact continuity |
| Cline Memory Bank | Yes | Partial | Yes | Limited | File-based | Less explicit about bias, debriefs and contribution visibility |
| `claude-mem` | Partial | Yes | No | Partial | Search/retrieval oriented | More machine-first and less inspectable |
| Oh My Codex | State files | Orchestration state | Partial | No | Mode/state oriented | Orchestration layer, not notes/debrief system |
| Obsidian stack | Yes | No by default | Possible | Custom | Link/source discipline possible | Needs agent workflow protocol |
| Electronic Lab Notebooks | Yes | No | Research logs | Limited | Strong audit tradition | Less tuned for AI-agent and software workflows |
| Postmortem templates | Yes | No | No | Strong for incidents | Evidence depends on practice | Only one layer |
| Zettelkasten | Yes | No | No | No | Link discipline | Weak on agent workflows and session learning |
| OriginTrail DKG | Graph-first | Possible | No | No | Strong verifiable provenance | Infrastructure substrate, not a human-readable work system |

## Closest Analogs By Layer

Closest to durable file memory:

- Claude Memory Bank;
- Cline Memory Bank;
- Claude Code Memory;
- Obsidian-based systems.

Closest to runtime memory:

- Claude Code Memory;
- `agentmemory`;
- `claude-mem`;
- ReasoningBank.

Closest to workflow learning:

- ReasoningBank;
- Agent Workflow Memory;
- postmortem practice;
- debrief/lessons systems.

Closest to provenance infrastructure:

- OriginTrail DKG;
- `agentmemory`;
- disciplined Obsidian/source-link setups.

## Where HARE Trail Should Be Distinct

- It treats human work as primary and AI memory as a layer.
- It keeps task folders, sources, journals, trackers, debriefs and lessons together.
- It separates reusable system logic from private data.
- It treats user corrections and failed hypotheses as first-class learning material.
- It is explicitly designed against overtrust, confirmation bias and context drift.
- It can later add runtime memory, embeddings or graph projections without replacing markdown as the inspectable source of truth.

## Current Weaknesses

- Automatic session capture is not implemented.
- Session-end distillation is not implemented.
- Tool-specific Claude wrappers and clean-checkout install validation are not yet complete.
- Clean-checkout setup has not been validated against the sanitized fixture yet.
- Search/index and graph/provenance layers are future work.
- Clean-checkout setup is not validated yet.

## Practical Positioning

HARE Trail should not claim to beat runtime memory tools at automatic capture.

Its stronger claim is different:

> Keep the human-readable path of work intact, then let agents use that path safely.
