# AGENTS.md

This repository contains the reusable HARE Trail system layer.

## Scope

Work in this repository should stay generic and publishable.

Do not add:

- personal notes;
- real `work-artifacts`;
- real `session-debriefs`;
- private `LESSONS.md`;
- raw exported chats;
- private source packets;
- hardcoded user-specific absolute paths.

Use sanitized examples or fixtures when a workflow needs sample data.

## System/Data Boundary

HARE Trail is expected to run with a separate data repository.

System repository:

- skills;
- templates;
- docs;
- scripts;
- integration wrappers;
- sanitized examples.

Data repository:

- work artifacts;
- notes;
- session debriefs;
- lessons;
- imported sources;
- personal or project overlays.

## Path Contract

Do not assume the data repository is inside this repository. Use an explicit configuration value such as `HARETRAIL_DATA_DIR` when tooling needs to locate real data.

When editing real user data, prefer running the agent from the data repository instead of making system commands write outside the current working directory.

## Documentation Style

Keep docs compact, direct and reusable. Explain the workflow contract and failure modes, not private history.

## Local-To-System Escalation

When a rule discovered in a private data repository looks reusable, do not silently leave it only in local config. Ask whether it should stay local, become an issue/discussion, or be prepared as a pull request to this system repository.
