# Task workflow

## Канонические пути

`{data-repo}` — root приватного HARE Trail data repo. Resolve it through `HARETRAIL_DATA_DIR`, then the current workspace if it has the expected data shape, then an explicit user/host-tool path. Do not hardcode personal absolute paths.

- Точка входа: `{data-repo}/AGENTS.md`
- Базовые правила: `{data-repo}/BASE.md`
- Модель task-folders: `{data-repo}/work-artifacts/README.md`
- Папка task-folders: `{data-repo}/work-artifacts/`

## Цель

Не начинать сложную работу "просто в чате", если пользователь хочет, чтобы она велась как отдельная задача.

Результат:

- найден или создан один task-folder;
- есть `README.md`, `tracker.md`, `journal.md`;
- при необходимости созданы `sources/`, `file-summaries/`, `prompts/`, `pr/`, `verification/`.
- если в folder мигрированы raw sources, у них должен появиться хотя бы один `file-summaries/packet-summary.md`.

## 1. Найти или создать

Приоритет:

1. Если пользователь дал явный путь или slug, использовать его.
2. Иначе поискать похожие папки в `work-artifacts/`.
3. Если найдено несколько правдоподобных кандидатов и риск ошибки высок, спросить пользователя.
4. Если ничего не найдено, создать `{slug}/`.

Default placement:

- По умолчанию новый task-folder создаётся в `{data-repo}/work-artifacts/`.
- Если пользователь явно просит создать artifact в текущем workspace/repo, использовать указанное место и зафиксировать это в `README.md`.
- Если task-folder создан в `{data-repo}` из контекста внешнего рабочего repo и к нему вероятно будут возвращаться в следующих сессиях, предложить пользователю создать `ln -s` в текущем repo для удобного доступа. Не создавать symlink молча.
- Новый значимый task-folder должен быть local git repo по умолчанию, если он не tiny/throwaway. Если repo author identity неоднозначна, спросить пользователя или применить local data config.
- Если task-folder является git repo, новые файлы, явно относящиеся к текущей задаче, нужно добавить в index (`git add <files>`) до завершения работы; unrelated user changes не stage-ить.

## 2. Минимальная структура

Новый task-folder должен иметь:

```text
README.md
tracker.md
journal.md
```

Опционально:

```text
sources/
file-summaries/
prompts/
pr/
verification/
architecture/
```

Для legacy import / repack дополнительно уместен:

```text
migration-log.md
```

Если в task-folder импортируются исходные документы:

- literal build/app-wrapper path не должен становиться каноническим путём хранения без необходимости;
- `prompts/` не надо создавать автоматически, если пользователь отдельно не просил prompt-артефакты.

## 3. Что писать

`README.md`

- что это за задача;
- зачем она открыта;
- какие репо/материалы связаны;
- source period / export date, если это migrated packet;
- где смотреть дальше.

`tracker.md`

- current question;
- current decisions;
- open questions;
- next step.

`journal.md`

- append-only записи;
- каждая запись помечается не только датой/временем, но и **агентом и
  id сессии**, в рамках которой делалась работа (например
  `27.05.2026 [Claude Code (Opus 4.7), сессия 717744a5]`). Это нужно,
  чтобы потом проще искать следы в session-логах
  (`~/.claude/projects/**/*.jsonl`, `~/.codex/sessions/**`);
- развилки;
- progress updates;
- важные цитаты.

`migration-log.md`

- когда это legacy import или большой перенос, фиксирует:
  - source dates;
  - export/import timestamp;
  - mapping `откуда -> куда`;
  - точность доступных дат.

## 4. Если пользователь просто говорит "давай вести это в папке задачи"

Default behavior:

- предложить существующий task-folder, если он явно подходит;
- иначе создать новый и положить туда стартовый context.

## 5. Связь с другими skills

- `summary` может наполнять task-folder sources и file summaries;
- `research` может вести tracker/journal внутри task-folder;
- `doc-write` может брать task-folder как источник для clean docs;
- `debrief` может читать task-folder как дополнительный материал.
