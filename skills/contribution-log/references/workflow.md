# Contribution Log workflow

## Канонические пути

`{data-repo}` — root приватного HARE Trail data repo. Resolve it through `HARETRAIL_DATA_DIR`, then the current workspace if it has the expected data shape, then an explicit user/host-tool path. Do not hardcode personal absolute paths.

- Точка входа: `{data-repo}/AGENTS.md`
- Базовые правила: `{data-repo}/BASE.md`
- Модель task-folders: `{data-repo}/work-artifacts/README.md`
- Папка task-folders: `{data-repo}/work-artifacts/`

## Когда использовать

Используй, когда пользователь хочет:

- вести contribution log;
- собирать evidence для self-review;
- фиксировать help given / help received;
- сохранять glue work и другой труднооцифровываемый вклад;
- импортировать workbook/logbook вроде `xlsx/csv/ods` с contribution history;
- подготовить материал для разговора с менеджером или review без потери контекста.

## Принцип

`contribution-log` — это слой видимости вклада и процесса, а не рейтинг и не перформанс-дашборд.

Главные принципы:

- не сводить вклад к счётчикам;
- различать `countable` и `intangible` contribution;
- сохранять кому именно был полезен вклад и какую проблему он снял;
- отдельно держать помощь от других и незавершённую, но значимую работу;
- хранить evidence links и короткий контекст, но не превращать лог в длинную автобиографию.

## 1. Найти или создать контейнер

Приоритет:

1. Если пользователь дал явный folder или slug, использовать его.
2. Иначе поискать похожие папки в `work-artifacts/`:
   - `contribution-log`
   - `self-review`
   - `work-visibility`
   - периодические варианты вроде `self-review-2026-h1`
3. Если ничего не найдено, по умолчанию создать:

```text
work-artifacts/contribution-log/
```

Если пользователь явно работает по периоду, допустимы container names вроде:

```text
work-artifacts/self-review-2026-h1/
work-artifacts/contribution-log-2026/
```

## 2. Минимальная структура

Новый container должен иметь:

```text
README.md
tracker.md
journal.md
logs/
  contributions.md
  received-help.md
  unfinished.md
```

Опционально:

```text
sources/
file-summaries/
evidence/
prompts/
```

`evidence/` уместен для:

- скриншотов;
- exported tables;
- pasted message drafts;
- вспомогательных артефактов self-review.

Если импортирован workbook/logbook, у него должен появиться хотя бы один:

```text
file-summaries/packet-summary.md
```

## 3. Что писать

`README.md`

- что это за contribution log;
- чей он;
- какой период покрывает;
- зачем ведётся;
- где смотреть дальше;
- как читать entries.

`tracker.md`

- текущий период;
- что уже собрано;
- каких evidence gaps не хватает;
- какие разделы надо добрать;
- какой следующий шаг для self-review packet.

`journal.md`

- append-only лог о том, как собирался и пересобирался contribution packet;
- сомнения;
- развилки;
- почему какие-то вещи были добавлены или исключены;
- важные user/manager quotes про оценку вклада и метрики.

`logs/contributions.md`

- что пользователь сделал для других или для системы;
- кому это помогло;
- какую проблему сняло;
- был ли вклад `countable`, `intangible` или смешанный;
- evidence links;
- почему это важно.

`logs/received-help.md`

- кто помог пользователю;
- с чем именно;
- как это повлияло на работу;
- есть ли follow-up или reciprocity note.

`logs/unfinished.md`

- что было начато, но не доведено;
- почему это всё равно значимо;
- почему остановлено;
- какие материалы уже есть;
- когда вернуться.

## 4. Формат entries

По умолчанию использовать датированные entries с краткой структурой:

```markdown
## DD.MM.YYYY

### {short title}

- Beneficiary:
- Type: `countable` | `intangible` | `mixed`
- Contribution:
- Problem solved / value created:
- Evidence:
- Notes:
```
```

Для `received-help.md`:

```markdown
## DD.MM.YYYY

### {person}

- Help:
- Why it mattered:
- Evidence:
- Follow-up:
```
```

Для `unfinished.md`:

```markdown
## DD.MM.YYYY

### {initiative}

- Problem / opportunity:
- Started:
- Not finished because:
- Why it still matters:
- Existing artifacts / evidence:
- Suggested next moment to revisit:
```
```

Если у пользователя уже есть spreadsheet или свой формат, не ломать его без необходимости:

- сохранить original в `sources/`;
- поверх него сделать structured summary и/или markdown replacement docs.

## 5. Табличные артефакты

Для `xlsx/csv/ods`:

- хранить оригинал как source of truth;
- не flattening-ить workbook в lossy plain text;
- фиксировать:
  - список листов;
  - смысл каждого листа;
  - ключевые колонки;
  - приблизительный объём;
  - что в этой таблице особенно ценно для self-review.

Если есть явные листы вроде:

- `кому помог`;
- `кто помог`;
- `начал, но не доделал`;

то сохранять эту семантику, а не схлопывать всё в одну простыню.

## 6. Что не делать

- не превращать contribution log в brag document без контекста;
- не удалять help received, оставляя только personal wins;
- не выбрасывать незавершённую работу, если она показывает важный, но труднооцифровываемый вклад;
- не подменять evidence риторикой;
- не использовать этот skill для session debrief или incident postmortem.

## 7. Связь с другими skills

- `task` может создать или найти контейнер;
- `summary` может импортировать workbook/chat/log packet в `sources/` и `file-summaries/`;
- `doc-write` может превращать contribution packet в clean self-review document;
- `lessons` может брать из contribution logs устойчивые паттерны, но только если они действительно повторяются;
- `research` может использовать такие пакеты как материал для тем про glue work, metrics и process visibility.
