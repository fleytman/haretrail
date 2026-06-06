# Goals And Use Cases

## Goals

HARE Trail exists to make long-running human-agent work recoverable, inspectable and easier to continue.

Primary goals:

- preserve the path of inquiry, not only final answers;
- keep work readable for humans and reusable by agents;
- separate reusable workflow logic from private working data;
- support cross-session, cross-tool and cross-repository continuity;
- turn mistakes into debriefs, lessons and improved workflows;
- keep evidence, source boundaries and corrections visible;
- make context sharing token-efficient through structure and summaries.

Non-goals:

- replacing human judgment with automatic memory;
- storing private work in the public system repository;
- making a database or vector store the primary source of truth;
- turning every note into a heavy process document;
- promising that bias or hallucination can be eliminated.

## Use Cases

### Cross-Repository Development

Use HARE Trail when a task spans multiple repositories, tools or pull requests.

Typical artifacts:

- task folder;
- tracker;
- journal;
- source links;
- verification notes;
- PR drafts;
- debrief after mistakes.

### Research

Use it when a question changes over time and needs sources, hypotheses, prompts, summaries and interpretation.

Typical artifacts:

- source packet;
- file summaries;
- research tracker;
- research journal;
- open questions;
- external AI prompts when explicitly requested.

### Document Packet Summaries

Use it for imported docs, PDFs, markdown exports, spreadsheets, chat logs and large prompts.

The goal is to preserve raw sources while producing summaries that can be used by a human or agent later.

### AI Chat Imports

Important AI conversations can become source artifacts.

They should be distinguished from:

- polished summaries;
- reusable prompts;
- durable notes;
- extracted lessons.

### Debriefs And Lessons

Use debriefs when a session contains mistakes, false hypotheses, user corrections or useful patterns.

Use lessons for distilled future-facing rules.

### Postmortems

Use postmortems only for heavier incident-grade analysis with timeline, impact, root cause and corrective actions.

### Contribution And Visibility Logs

Use contribution logs for invisible work, glue work, review support, self-review evidence and work that should not disappear because it was not a shipped artifact.

### Future Runtime Memory

Runtime memory, search, embeddings and graph projections can be added later.

They should remain layers over inspectable artifacts, not replacements for them.

## Expected Data Repository Shape

The private data repository is expected to contain:

```text
work-artifacts/
notes/
session-debriefs/
postmortems/
LESSONS.md
```

The reusable system repository should contain the workflows, templates and integration code that operate on that data shape.
