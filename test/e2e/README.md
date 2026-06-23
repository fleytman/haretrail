# Runtime skill-loading e2e

A containerized end-to-end test that launches the **real** agent CLIs
(Claude Code, Codex) against a clean checkout and drives them through a HARE
Trail workflow — the "runtime loading not validated" item from the README
status list.

Unlike `test/smoke` (offline, free, validates the install scripts), this test
makes **live, paid API calls** and needs auth tokens.

## Portability

This harness encodes none of our local setup. You choose two things:

- the **Docker runtime** — it uses your active `docker` context (Colima, Docker
  Desktop, a remote engine, ...); any runtime named here is only an example;
- how **auth keys** are provided — through the standard environment variables
  below, by whatever method you prefer. A secret manager such as 1Password is
  optional, not required, and no vault, key reference or machine path is
  committed here.

## What it does

Inside a Node + git container, with a clean install in place, it asks each agent
to:

1. use the `research` skill to create a task-folder structure,
2. write `README.md` / `tracker.md` / `journal.md` into the data repo's
   `work-artifacts/`,
3. run whitelisted commands (`git init`, `git add`) in the new task folder.

It then asserts on the **data-repo filesystem** (the durable evidence), not on
chat text. Each selected agent uses its own scaffolded data repo so results are
independent.

## Auth

Auth is read from environment variables — the standard, device-independent
interface:

| Agent  | Variable |
| ------ | -------- |
| Codex  | `OPENAI_API_KEY` |
| Claude | `CLAUDE_CODE_OAUTH_TOKEN` (from `claude setup-token`) or `ANTHROPIC_API_KEY` |

Set them however you like and run:

```bash
export OPENAI_API_KEY=...            # codex
export CLAUDE_CODE_OAUTH_TOKEN=...   # claude (or ANTHROPIC_API_KEY)
test/e2e/run-e2e.sh
```

The tokens are forwarded into the container **by name only** — no value is
printed and none is written to disk. A selected agent with no token is skipped,
not failed.

> Note: a Claude desktop subscription login stored in the OS keychain cannot be
> forwarded into a Linux container — mint a portable token with
> `claude setup-token` (Pro/Max) or use an API key.

> Optional: if you keep secrets in a manager such as 1Password, you can inject
> them at run time, e.g. `op run -- test/e2e/run-e2e.sh`. Any equivalent
> mechanism that exports the variables above works the same.

## Run

```bash
test/e2e/run-e2e.sh                 # both agents, local checkout
test/e2e/run-e2e.sh --codex-only
test/e2e/run-e2e.sh --claude-only
test/e2e/run-e2e.sh --github        # test the published repo
test/e2e/run-e2e.sh --build-only    # build image only; no tokens, no calls
```

## Security

Only the auth variables above are passed into the container. The probe prompt
and the skill text are sent to the respective model provider (OpenAI /
Anthropic) — that is the point of the test. The host repo is mounted read-only.

## Files

- `Dockerfile` — Node image with `@anthropic-ai/claude-code` and `@openai/codex`.
- `bootstrap.sh` — materializes the clean checkout, then runs the e2e.
- `container-e2e.sh` — clean install, drives agents through the workflow, asserts.
- `run-e2e.sh` — host helper: builds the image and forwards tokens by name.
