---
name: summary
description: "Process a packet of documents or files for {data-repo}: copy sources into work-artifacts, convert heavy formats to markdown/text, write an overall summary, file summaries, extract important quotes, build a mermaid diagram and, if needed, generate prompts for further research."
---

# Summary

This skill handles batch processing of documents and source-packets in `{data-repo}`.

Before working:

- Read `../_shared/system-behavior.md` as the shared reusable behavior contract.

- Read `references/workflow.md` and follow it as the source of truth.
- Treat only paths in `{data-repo}` as canonical, not `.claude` or `.codex`.
- Write working artifacts in the language configured as HARETRAIL_ARTIFACT_LANG in the local config (~/.haretrail/config.env); if unset, fall back to the language of the current user/dialogue. Do not hardcode a specific language.

Use this skill when you need to:

- work through a batch of documents;
- assemble `sources/` and `file-summaries/`;
- preserve important thoughts and quotes;
- prepare a packet for future research;
- avoid losing context from pdf/docx/md/txt and similar formats.
