---
name: debrief
description: "Read, create and update session debriefs and LESSONS.md in {data-repo} when the user asks for a debrief, debrief all, show debriefs, create a debrief, write a debrief, enrich a debrief, add mistakes or lessons to a debrief. When related work-artifacts exist, use them as additional material. Do not use for ordinary notes outside this system."
---

# Debrief

This skill handles the canonical session-debriefs system in `{data-repo}`.

Before working:

- Read `../_shared/system-behavior.md` as the shared reusable behavior contract.
- Read `references/workflow.md` and follow it as the source of truth.
- Treat only paths in `{data-repo}` as canonical, not those in `.claude` or `.codex`.
- Write working artifacts in the language configured as HARETRAIL_ARTIFACT_LANG in the local config (~/.haretrail/config.env); if unset, fall back to the language of the current user/dialogue. Do not hardcode a specific language.

If the user's request is ambiguous, first determine the mode: overview of all debriefs, reading a specific debrief, or writing/enriching a debrief.
