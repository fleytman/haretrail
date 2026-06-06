# Commands

HARE Trail commands are workflow contracts. The command names can be exposed as skills, slash commands, scripts or agent instructions depending on the host tool.

| Command | Use When | Main Output | Writes To Data Repo |
| --- | --- | --- | --- |
| `task` | Work needs to survive a session or model switch. | Task folder with README, tracker and journal. | `work-artifacts/` |
| `summary` | A packet of files, docs, exports or sources must be summarized. | Source packet, file summaries, quotes, optional prompts. | `work-artifacts/{task}/` |
| `research` | A question needs hypotheses, checks, sources and evolving interpretation. | Research tracker, journal, sources and summaries. | `work-artifacts/{task}/` |
| `doc-write` | Documentation must be written or updated for a repository. | Human-readable docs following local repo rules. | Target repo or task folder |
| `debrief` | A session produced mistakes, false hypotheses or lessons. | Session debrief and updated lessons index. | `session-debriefs/`, `LESSONS.md` |
| `lessons` | Lessons must be read, added or refined without a full debrief. | Distilled lesson updates. | `LESSONS.md` |
| `postmortem` | An incident-grade analysis is needed. | Timeline, impact, root cause, corrective actions, lessons. | `postmortems/` |
| `contribution-log` | Contribution, invisible work or self-review evidence must be recorded. | Contribution log or visibility artifact. | Data repo work artifacts or notes |

## Command Rules

- Do not silently create prompt artifacts unless the user requested prompts or a research packet.
- Do not treat tracked repository docs as private work artifacts.
- Do not treat untracked scratch markdown as canonical project documentation.
- Do not mix debriefs, lessons and incident-grade postmortems into one workflow.
- Do not make system commands depend on private absolute paths.
