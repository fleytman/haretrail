---
name: research
description: "Run a research task in {data-repo}: create or update a task-folder, collect/summarize sources, build a research plan, record questions and forks, keep a tracker and journal, generate prompts for external research AIs."
---

# Research

This skill handles research tasks in `{data-repo}`.

Before working:

- Read `../_shared/system-behavior.md` as the shared reusable behavior contract.

- Read `references/workflow.md`.
- If there is an input packet of documents, first apply the `summary` logic.
- Write working artifacts in the language configured as HARETRAIL_ARTIFACT_LANG in the local config (~/.haretrail/config.env); if unset, fall back to the language of the current user/dialogue. Do not hardcode a specific language.

Use this skill when the user asks for:

- research;
- a research plan;
- a deep dive into a topic;
- assembling a question, hypotheses and a verification path;
- preparing a packet for external research AIs.
