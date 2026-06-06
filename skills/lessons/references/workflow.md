# Lessons workflow

## Канонические пути

`{data-repo}` — root приватного HARE Trail data repo. Resolve it through `HARETRAIL_DATA_DIR`, then the current workspace if it has the expected data shape, then an explicit user/host-tool path. Do not hardcode personal absolute paths.

- `LESSONS.md`: `{data-repo}/LESSONS.md`
- Дебрифы: `{data-repo}/session-debriefs/`
- Work artifacts: `{data-repo}/work-artifacts/`

## Когда использовать

Используй, когда пользователь просит:

- показать lessons;
- добавить lesson;
- уточнить существующий lesson;
- перегруппировать lessons.

## Режимы

### Read

- показать relevant sections из `LESSONS.md`;
- если нужно, сослаться на связанные debrief/task artifacts.

### Write

- добавить lesson только если он реально подтверждён;
- не раздувать `LESSONS.md` шумом;
- если нужен полный разбор, предложить или использовать `debrief`.

## Принцип

`lessons` — это слой distilled patterns, а не место для подробной хроники.
