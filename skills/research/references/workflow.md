# Research workflow

## Canonical paths

`{data-repo}` — root of the private HARE Trail data repo. Resolve it through `HARETRAIL_DATA_DIR`, then the current workspace if it has the expected data shape, then an explicit user/host-tool path. Do not hardcode personal absolute paths.

- Entry point: `{data-repo}/AGENTS.md`
- Base rules: `{data-repo}/BASE.md`
- Task-folders: `{data-repo}/work-artifacts/`
- Summary workflow: `skills/summary/references/workflow.md` in the HARE Trail system repo
- Durable notes: `{data-repo}/notes/`

## When to use

Use this workflow when the user wants not just a summary of sources but full research:

- there is a question that will change and get refined;
- hypotheses, checks and forks are needed;
- you need to collect not only documents but the line of reasoning itself;
- prompts for further deep research are needed;
- the task may span several repositories, conversations and external materials.

## Result

The output should be a task-folder with at minimum:

```text
{task-folder}/
  README.md
  tracker.md
  journal.md
  sources/
  file-summaries/
```

Add `prompts/` only when the user asks to prepare them for external research AIs or it is explicitly part of the requested output.

Default placement:

- By default a new research artifact is created in `{data-repo}/work-artifacts/`.
- If the user explicitly asks to create the artifact in the current workspace/repo, use the specified location and record this in `README.md`.
- If a research folder is created in `{data-repo}` from the context of an external working repo and it will likely be revisited in future sessions, suggest that the user create an `ln -s` in the current repo for convenient access. Do not create the symlink silently.
- A new significant research artifact should be a local git repo by default, unless it is tiny/throwaway. If the repo author identity is ambiguous, ask the user or apply the local data config.
- If the research folder is a git repo, new files that clearly belong to the current research must be added to the index (`git add <files>`) before the work is finished; do not stage unrelated user changes.

## 1. Gather context

1. If there is an input packet of documents, run it through the `summary` logic.
2. If there are no documents but there is a question, create a task-folder and record the starting context manually.
3. If the starting material is a conversation with an AI, a large prompt or an export of an external chat, store the raw artifact in `sources/` and record this in `README.md`.
4. If the question is very ambiguous and the research would be junk without clarification, ask the user short questions.

## 2. Record the starting state

In `tracker.md` write:

- the wording of the question as it is now;
- why this research is being done;
- constraints;
- the current working hypothesis;
- what the output should be.

## 3. Build a research plan

The plan should be short and verifiable:

- which directions to check;
- which data/sources are needed;
- which hypotheses are vulnerable;
- which questions to ask the user;
- which external research AIs can be used later.

## 4. Keep `journal.md`

`journal.md` is append-only.

Record:

- how the question changed;
- what the user assumed;
- what the agent assumed;
- what was checked;
- what turned out to be false;
- what turned out to be a strong counterexample;
- how the understanding changed;
- important quotes from the user and the AI.

## 5. Mandatory sections

### In `tracker.md`

- Current question
- Current hypothesis
- What contradicts the current model
- Open questions
- Next step

### In `journal.md`

- timestamp
- question at this moment
- attempt
- evidence
- result
- interpretation

## 6. Prompts

If the research is worth continuing with external systems, create prompts in `prompts/` only when:

- the user explicitly asked for prompt files;
- the user asks for a research packet for an external system;
- prompts already exist in the current task-folder as an explicit artifact type.

Typical prompts:

- `deep-research-prompt.md`
- `compare-approaches-prompt.md`
- `critique-current-model-prompt.md`
- `extract-durable-notes-prompt.md`

Language rule for prompt files:

- without a separate instruction from the user, write reusable prompts in the language of the current dialogue;
- if the external tool or the target audience clearly requires another language, first clarify this with the user or make parallel versions with explicit marking (`-ru`, `-en`);
- do not leave a canonical prompt file in a "randomly chosen" language without marking.

## 7. Transition into durable notes and debriefs

After a significant stage it is useful to decide:

- what should be moved into `notes/` as a durable note;
- what should be moved into `session-debriefs/` as a debrief about a mistake or false hypothesis.
- what should be saved as a reusable prompt or summary for switching between models and future sessions.

Do not confuse these layers:

- research = line of reasoning and investigation;
- debrief = lessons and mistakes;
- notes = durable knowledge.
