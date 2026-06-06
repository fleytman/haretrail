# Postmortem workflow

## Канонические пути

`{data-repo}` — root приватного HARE Trail data repo. Resolve it through `HARETRAIL_DATA_DIR`, then the current workspace if it has the expected data shape, then an explicit user/host-tool path. Do not hardcode personal absolute paths.

- Папка postmortems: `{data-repo}/postmortems/`
- README postmortems: `{data-repo}/postmortems/README.md`
- Lessons: `{data-repo}/LESSONS.md`

## Когда использовать

Используй только для тяжёлых случаев, где нужен детальный incident analysis.

## Формат

```markdown
# {Title} Postmortem

Date: DD.MM.YYYY HH:mm:ss.SSS
Scope:
Status:
Report Type: Auto-report
Report Author: {Agent}
Agent Runtime Label: {exact label if known, else `not recorded`}
User Label: {preferred user label or `Пользователь`}
Narrative Mode: actor-labeled

## Summary
## Timeline
## Impact
## 5 Whys
## Winback Plan
## Lessons Learned
## Other Details
```

## Принцип

- Не every mistake deserves a postmortem.
- `postmortem` = heavy, explicit, structured, incident-grade.
- Session-level mistakes обычно идут в `debrief`.
- В auto-generated postmortems агент не пишет безличное `я`; использовать явные actor labels.
- В `Timeline` сразу после `Summary` стремиться писать точные timestamps; если точное время недоступно, явно указывать доступную точность.
- В `Timeline` использовать точные цитаты, когда они критичны для разворота ситуации.
- `5 Whys` по умолчанию можно дать как draft от агента, но это должна быть зона, которую пользователь может уточнить или переписать.
