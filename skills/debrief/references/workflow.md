# Debrief workflow

## Canonical paths

`{data-repo}` — root of the private HARE Trail data repo. Resolve it through `HARETRAIL_DATA_DIR`, then the current workspace if it has the expected data shape, then an explicit user/host-tool path. Do not hardcode personal absolute paths.

- Entry point: `{data-repo}/AGENTS.md`
- Base rules: `{data-repo}/BASE.md`
- Lessons index and debrief map: `{data-repo}/LESSONS.md`
- Debrief storage directory: `{data-repo}/session-debriefs/`
- Debrief format and purpose: `{data-repo}/session-debriefs/README.md`
- Working task-folders and imported artifacts: `{data-repo}/work-artifacts/`

Use these paths as the source of truth, even if there is a symlink somewhere in `.claude`, `.codex` or another service folder.

## Determine the mode

Treat the request as read mode if the user asks to:
- `debrief all`
- show debriefs
- show the lessons/debrief map
- read a specific existing debrief

Treat all other requests of the form `debrief`, `write a debrief`, `create a debrief`, `enrich a debrief`, `add mistakes/lessons to a debrief` as write mode.

## Read mode

1. Read `{data-repo}/LESSONS.md`.
2. Briefly show the debrief map and the key lessons.
3. If the user asked for details, read the relevant file from `{data-repo}/session-debriefs/` and show it briefly and concretely.

## Write mode

### 1. Determine the feature

Determine the feature slug as follows:
- If the user explicitly named a slug, a task or a specific debrief file, use it.
- Otherwise take the current git branch via `git branch --show-current 2>/dev/null`.
- Strip prefixes `fix/`, `feature/`, `feat/`, `hotfix/`, `bugfix/`, `chore/`.
- Convert the remainder to kebab-case.
- If the branch is empty, `main`, `master`, `develop`, or the current directory is not a git repository, ask the user.

### 2. Determine the repository

- Use `basename "$(git rev-parse --show-toplevel 2>/dev/null)" 2>/dev/null`.
- If not in a git repository, ask the user.

### 3. Find an existing debrief

- Search by the pattern `{data-repo}/session-debriefs/*{slug}*`.
- If a file is found, read it and enrich it without rewriting the existing content.
- If not found, create `{data-repo}/session-debriefs/YYYY-MM-DD-{slug}-debrief.md`.

### 4. Collect material from the session

From the history of the current conversation, collect:
- Participant mistakes:
  - mistakes of the current agent with an explicit name (`Codex`, `Claude Code`, etc.);
  - mistakes of the user, if they matter to the dynamics of the task;
  - mistakes of other agents, if they appear in the material.
- False hypotheses:
  - where possible, separate them by participant rather than mixing them into one mass.
- User corrections: where the user redirected and why.
- What actually worked: the root cause, the confirmed fix, what it was verified with.
- Conclusions: rules for future sessions.
- If user-side errors or missing constraints look likely but are not fully made explicit:
  - do not understate this layer out of politeness;
  - check whether there was a misleading UI cue, an incomplete hypothesis, a hidden constraint or an unstated operational assumption;
  - if needed, ask 1-3 short questions to the user before finalizing the debrief.

Be concrete:
- name files, functions, branches, tools and exact symptoms
- record why a hypothesis or fix was wrong
- add short user quotes if they clearly show a correction or a constraint
- add short meaningful agent quotes if they clearly show a false hypothesis, premature closure, wrong confidence or a useful pivot
- if there is a quote, prefer the direct deliberate text rather than large embedded chunks of code/logs
- if a long quote contains a lot of noise, shorten it to its semantic core; remove the rest, marking the omission with `...`, but do not rewrite the key meaning
- do not use the ambiguous `My mistakes`; the actor must be named explicitly

### 4a. If there are related work-artifacts

If there is a related task-folder or working markdown files in `{data-repo}/work-artifacts/` on the same topic, use them as an additional source of facts.

Reading priority:

1. `README.md`
2. `tracker.md`
3. `journal.md`
4. `pr/`
5. `verification/`
6. `file-summaries/`

From them it is useful to extract:

- confirmed symptoms and verifications;
- forks and false hypotheses;
- key quotes from the user and the agent;
- what was considered the current model of the problem at different stages.

### 5. Update the debrief file

If the file is new, use this template:

```markdown
# {Title} Debrief

Date: YYYY-MM-DD
Repo: {repo name}
Task: {short description}
Report Type: Auto-report
Report Author: {Name of the current agent}
Agent Runtime Label: {exact label if known, else `not recorded`}
User Label: {preferred user label or `User`}
Narrative Mode: actor-labeled
Session Tool: {Codex / Claude Code / other if known}
Session ID: {id if known, else `not recorded`}
Resume Handle: {recoverable handle or raw session path hint if any, else `not recorded`}

## Participant mistakes
### {Name of the current agent}
### User
### Other agents

## False hypotheses
### {Name of the current agent}
### User
### Other agents

## User corrections
## Key user quotes
## Key agent quotes
## What worked
## Conclusions
```

Add `### Other agents` only if there is actual material there.
If a separate user name is not configured, use `User`.
If the exact runtime model / reasoning effort is not reliably known, do not invent it; write `Agent Runtime Label: not recorded`.
If `Session Tool`, `Session ID` or `Resume Handle` are unknown, do not make them up; write `not recorded`.

If the file already exists:
- Add only new facts and lessons.
- Do not duplicate existing items.
- Do not rewrite history after the fact.
- If a new update happened on a different day, add the marker `### Update YYYY-MM-DD`.
- If an old entry turned out to be wrong, append a correction rather than erasing the previous thought.

## Writing principles

- Language: write in the language configured as HARETRAIL_ARTIFACT_LANG in the local config (~/.haretrail/config.env); if unset, fall back to the language of the current user/dialogue. Do not hardcode a specific language.
- Tone: an honest postmortem, without smoothing over mistakes.
- Focus: why it happened, not only what was done.
- Write only about facts that actually occurred in the session.
- If there are working artifacts, do not copy them wholesale into the debrief; extract only the lessons, mistakes, false moves and the confirmed outcome.
- For actor-aware records, explicitly name the participant in the section or sub-item rather than using pronouns like `I` or `we` when this creates ambiguity.
- In auto-generated persistent docs do not use the first person on behalf of the agent; the central `I`, if desired, can only be the user in their own additions.
- If user-side mistakes are barely recorded but the user repeatedly corrected the agent or the history contains questionable premises, that is a reason to check the user-side assumptions layer separately rather than automatically writing "there were no mistakes".

### 6. Update LESSONS.md

In `{data-repo}/LESSONS.md` you need to:
- add or refine a line in the debrief map
- add new lessons to the appropriate categories without duplicating existing ones
- update the error statistics if a genuinely new confirmed case of a pattern appeared

If the edit only refines the wording of an already counted pattern, do not increment the counters automatically.
