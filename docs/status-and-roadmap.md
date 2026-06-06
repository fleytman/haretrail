# Status And Roadmap

This file separates what is available now from the target HARE Trail system.

## Current Status

| Area | Status | Notes |
| --- | --- | --- |
| System/data boundary | Complete | Reusable system files stay in this repo; private work belongs in a separate data repo. |
| Public philosophy and goals | Complete | The docs explain the core position, goals and use cases without private history. |
| Command contracts | Complete | Workflow contracts are documented, but the migrated skill implementations are not present yet. |
| Claude/Codex setup contract | Drafted | The intended two-repository setup and permission model are documented. |
| Skills | Planned | `skills/` is a Phase 3 migration target. |
| Integrations | Planned | `integrations/` is a Phase 3 migration target. |
| Templates | Planned | `templates/` is a Phase 3 migration target. |
| Scripts | Planned | `scripts/` is a Phase 3 migration target. |
| Examples | Planned | `examples/` should contain sanitized fixtures only. |
| Clean-checkout install | Not validated | There is no installer yet. |

## Maturity Labels

- `Complete`: the public contract exists and can be used for orientation.
- `Drafted`: the contract exists, but needs implementation or clean-checkout validation.
- `Planned`: directory or concept exists, but reusable assets are not migrated.
- `Not validated`: the expected behavior has not been tested from a clean checkout.

## Roadmap

### Phase 3: Migrate Reusable Assets

- Move reusable skills into `skills/`.
- Remove hardcoded private paths.
- Replace private storage assumptions with configuration such as `HARETRAIL_DATA_DIR`.
- Add reusable templates for task folders, research packets, summaries, debriefs and postmortems.
- Add sanitized examples that demonstrate shape without real private work.

### Phase 4: Add Host Integrations

- Add Claude wrappers.
- Add Codex-compatible skill layout.
- Add connector install scripts.
- Validate that generated connectors do not embed private paths.

### Phase 5: Validate From Clean Checkout

- Create a disposable data repo fixture.
- Install connectors into a clean host-tool configuration.
- Run smoke checks against the fixture.
- Document the supported setup path.

### Later: Runtime Memory And Retrieval

Runtime memory, embeddings, graph projections and provenance indexes can be added later. They should remain layers over inspectable files, not replacements for the human-readable source of truth.
