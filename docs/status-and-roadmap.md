# Status And Roadmap

This file separates current maturity from the product roadmap after publication.

## Current Status

| Area | Status | Notes |
| --- | --- | --- |
| System/data boundary | Usable | Reusable system files stay in this repo; private work belongs in a separate data repo. |
| Public philosophy and goals | Usable | The docs explain why the system exists and what it is for. |
| System behavior | Drafted | Reusable behavior is documented, but still needs validation through real installs. |
| Command contracts | Usable draft | Core workflow contracts and reusable skill source folders are present. |
| Data repo initialization | Drafted | `init-data-repo.sh` creates a minimal private scaffold. |
| Connector installer | Install-tested | Source-link and generated thin-wrapper modes exist. |
| Claude/Codex setup | Drafted | Setup contract exists; fresh runtime loading still needs validation. |
| Templates | Drafted | Core templates are present and need more real-use hardening. |
| Examples | Drafted | A fictional fixture data repo exists for smoke checks. |
| Runtime loading | Not validated | Actual Claude/Codex skill loading is not proven from clean fresh sessions. |
| Docker/container smoke | Planned | Fixture-only install checks are planned, not implemented. |

## Maturity Labels

- `Usable`: enough for orientation and early use, but not a stability promise.
- `Drafted`: the concept or asset exists and needs real-use validation.
- `Install-tested`: installer mechanics were verified, but host-tool runtime behavior is not fully proven.
- `Planned`: no reusable implementation yet.
- `Not validated`: expected behavior has not been proven.

## Publication Gate

Before public claims or a colleague demo, verify:

- privacy scan: no private paths, company references or personal corpus in this repo;
- clean checkout install path;
- `init-data-repo.sh` scaffold from scratch;
- connector install into disposable tool homes;
- duplicate skill discovery behavior for Codex and Claude;
- at least one fixture-only workflow smoke;
- clear docs for system repo vs data repo.

## Product Roadmap

### 1. Reliable Setup And Smoke Tests

Goal: make first install boring.

- One-command local setup for a system repo plus data repo.
- Fixture-only smoke tests for init, connector install and wrapper rendering.
- Docker/container smoke for clean checkout validation.
- Tool-specific connector policy so one skill does not appear twice in the same host UI.
- Safer destructive-operation guidance: backup is not enough when running sessions depend on the path being changed.

### 2. Data Repo Versioning Policy

Goal: make lessons and debriefs rollback-able without breaking task repos.

- Define default git policy for the private data repo.
- Track durable memory layers such as lessons, debriefs, notes and postmortems.
- Keep `work-artifacts/` compatible with standalone per-task repos.
- Avoid submodules by default unless a task artifact is intentionally published/shared.
- Add scripts or docs for checking nested repo status before commits.

### 3. Session-Start Retrieval

Goal: load the right lessons without flooding context.

- Retrieve lessons by repo, task type, tool, failure mode and source boundary.
- Link each lesson to debrief evidence.
- Avoid cross-repo hallucination from overly broad similarity search.
- Add a bounded preflight section for agents: what to read before acting.

### 4. Multi-Thread Dialogue Resilience

Goal: reduce salience errors in long human-agent conversations.

- Explicit thread markers: current task, correction, new packet, side question, durable decision.
- Inbox-like triage for files and prompts sent mid-session.
- Branch/re-entry summaries for long-running tasks.
- Better handoff between task folders, debriefs and durable notes.

### 5. Ingestion And Source Packets

Goal: make imports reliable and cheap to revisit.

- Chat export/import conventions.
- PDF/DOCX/spreadsheet conversion guidance.
- Structured source indexes with source date, import date, conversion notes and quotes.
- Prompt packet conventions for external research systems.

### 6. Language Strategy

Goal: support non-English users without fragmenting the reusable system.

- Keep working artifacts in the user or project language.
- Keep public system docs in English first, with selected translated docs where useful.
- Define sync rules for bilingual docs and prompts.
- Avoid assuming English skills are always optimal for non-English users.

### 7. Runtime Memory, Search And Provenance

Goal: add machine help without losing file-first inspectability.

- Lightweight search/index over markdown artifacts.
- Optional embeddings over summaries and lessons.
- Provenance graph projection for relations such as `derived-from`, `verified-by`, `supersedes`, `contradicts`.
- MCP layer after first demo/publication, not as a v0 setup blocker.
- Runtime memory remains a projection over files, not the canonical store.

## Migration Status

The earlier Phase 1-5 migration work produced this repository, reusable skills, templates, connector scripts, fixture data and the initial data repo scaffold. That migration status is implementation history, not the long-term product roadmap.

Remaining migration-hardening items:

- prove Claude/Codex runtime loading from fresh sessions;
- add fixture/container smoke;
- decide data repo git policy;
- clean up duplicate skill discovery;
- keep privacy scans clean before any public push.
