# Analogs Comparison

This is a compact public comparison. It is not a full research log.

## Why this list exists, and how to read it

A note on intent, method, and limits — so you can weigh the comparison honestly:

1. **Why publish at all.** HARE Trail started as a tool its author built for himself. It is shared because the author believes the *approach* may be useful to other people — and because surveying the field showed there is no off-the-shelf analog for what it tries to be (more on that below). It is an early proof of concept: not feature-rich, not optimized yet — the bet is on the philosophy behind it.
2. **What the author is actually trying to build.** Not "a dev tool" and not "a research tool" — an attempt to bring together best practices from *science* and from *software engineering* into one tool that supports human cognitive work: treating reasoning and questions as no less important than answers, treating rejected hypotheses as worth keeping and revisiting, and applying care to a user's work the way one would to user data. That combination is the point, and it is what the analog search struggled to find elsewhere.
3. **Why collect analogs.** To find the best ideas and the strongest candidates for integration — so as not to reinvent the wheel. Where a dedicated tool is clearly better for a slice of the problem (incident postmortems, session-based exploratory testing, plain project continuity, runtime memory), it is named as a recommended pairing, and HARE Trail composes with it rather than competing.
4. **Most analogs have not been used hands-on.** They were found and read, and an AI was pointed at their repositories to surface similarities and insights. Conclusions here are based on reading source and docs, not on personally running each tool — treat them as a literate review, not benchmarked verdicts.
5. **The catalogue itself may be useful to you.** If you are looking for this class of tools, you can reuse the map. A flat, link-only catalogue of everything surveyed is in [analogs-index.md](analogs-index.md) — pointers only, no verdicts, so you can explore yourself. Suggestions of further analogs, especially direct ones, are very welcome.

**On uniqueness.** No individual feature here is unique — durable lessons, user corrections, retrospectives, task continuity, provenance all exist elsewhere. The claim is compositional, and it is about *what the tool is for*: HARE Trail combines a source-bound research/work dossier, verification evidence, debrief/lessons/postmortem, and contribution/invisible-work accounting in a portable, human-readable system/data split — a *synthesis* of process-first reasoning and artifact-first files with evidence-based (not merely textual) verification, aimed at general human+AI work and research rather than a single vertical. The survey did not turn up an existing tool occupying that exact spot; see the axis section below.

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

## Spec-Driven Development And The Process/Artifact Axis

A common first-glance reaction is "this looks like spec-driven development (SDD)". SDD tools (OpenSpec, GitHub Spec Kit, Kiro, BMAD, Tessl, Agent OS) and HARE Trail share a surface: files-over-chat, a folder per unit of work, markdown in git, slash commands, the same host agents. The difference is the goal.

A useful frame is one axis with two poles and a synthesis between them:

- **Artifact-first / spec-first** — a specification of intent is the source of truth, written before the code; the spec drives generation and is archived after merge. Optimizes producing code. Examples: Spec Kit, Kiro, BMAD, OpenSpec.
- **Process-first** — judgment, context and the act of inquiry are primary; lightweight artifacts (charters, session logs, debriefs) serve the process rather than prescribe it. Optimizes learning and checking behaviour. Examples: context-driven testing / SBTM, Rapid Reporter, electronic lab notebooks.
- **Synthesis** — the reasoning process stays primary, but is preserved in durable, inspectable, versioned files. Examples that reach this for narrow domains: explore-qa and Superpowers (QA / coding sessions), Spec Kitty (governed worktree workflow).

A second axis worth tracking is the **type of verification** a tool offers: evidence-based (real runs) vs textual (one model checks another against the spec text) vs none. Most SDD tools verify textually; the synthesis tools verify with real runs.

| Approach | Source of truth | Pole | Verification | Main gap vs HARE Trail |
| --- | --- | --- | --- | --- |
| OpenSpec / Spec Kit / Kiro / BMAD | spec of intent | artifact-first | textual (spec coverage) | no research provenance, debriefs, lessons or contribution layer; delivery-oriented |
| Agent OS | coding standards | center | none | standards injection only, no research/debrief/verification |
| explore-qa / Superpowers | session process / executable skill | synthesis | evidence-based | narrow to QA / coding; no cross-session lessons or research dossier |
| Spec Kitty | mission state in repo | synthesis | evidence-based (worktrees) | heavier formalism; delivery/dev focus |
| SBTM / context-driven testing | exploratory session | process-first | human judgment | a methodology, broader than one tool; QA focus |
| Electronic Lab Notebooks / ADR | experiment log / decision record | process-leaning | none / fitness functions | not tuned for AI-agent software workflows |

Where HARE Trail sits: it claims the **synthesis** position — process-first epistemology preserved through an artifact-first filesystem — but for general **work and research**, not only for QA or a single coding feature. SDD and process-first tools are pattern donors HARE Trail can integrate for a given slice, not competitors for the whole system.

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
