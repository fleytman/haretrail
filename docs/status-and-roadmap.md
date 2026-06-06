# Status And Roadmap

This file separates what is available now from the target HARE Trail system.

## Current Status

| Area | Status | Notes |
| --- | --- | --- |
| System/data boundary | Complete | Reusable system files stay in this repo; private work belongs in a separate data repo. |
| Public philosophy and goals | Complete | The docs explain the core position, goals and use cases without private history. |
| Command contracts | Complete | Workflow contracts are documented and reusable skill source folders are present. |
| Claude/Codex setup contract | Drafted | The intended two-repository setup and permission model are documented. |
| Skills | Drafted | Reusable skill source folders are present; connector installation is not validated. |
| Integrations | Drafted | Source skill links can be installed; tool-specific Claude wrappers are not done. |
| Templates | Drafted | Reusable templates for core artifact types are present. |
| Scripts | Drafted | `install-connectors.sh` exists; validators and smoke tests are not done. |
| Examples | Drafted | A small fictional data repo fixture is present for future smoke checks. |
| Clean-checkout install | Not validated | There is no installer yet. |

## Maturity Labels

- `Complete`: the public contract exists and can be used for orientation.
- `Drafted`: the contract or reusable source exists, but needs implementation, installation or clean-checkout validation.
- `Planned`: directory or concept exists, but reusable assets are not migrated.
- `Not validated`: the expected behavior has not been tested from a clean checkout.

## Roadmap

### Phase 3: Migrate Reusable Assets

- Move reusable skills into `skills/`. Initial source migration is done.
- Remove hardcoded private paths. Initial skill path sanitization is done.
- Replace private storage assumptions with configuration such as `HARETRAIL_DATA_DIR`. Initial skill placeholder is `{data-repo}`.
- Add reusable templates for task folders, research packets, summaries, debriefs and postmortems. Initial template migration is done.
- Add sanitized examples that demonstrate shape without real private work. Initial fixture data repo is done.

### Phase 4: Add Host Integrations

- Add Claude wrappers.
- Add Codex-compatible skill layout. Initial source-link installer is done.
- Add connector install scripts. Initial source-link installer is done.
- Validate that generated connectors do not embed private paths.

### Phase 5: Validate From Clean Checkout

- Create a disposable data repo fixture.
- Install connectors into a clean host-tool configuration.
- Run smoke checks against the fixture.
- Document the supported setup path.

### Later: Runtime Memory And Retrieval

Runtime memory, embeddings, graph projections and provenance indexes can be added later. They should remain layers over inspectable files, not replacements for the human-readable source of truth.
