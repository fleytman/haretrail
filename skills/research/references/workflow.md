# Research workflow

## Канонические пути

`{data-repo}` — root приватного HARE Trail data repo. Resolve it through `HARETRAIL_DATA_DIR`, then the current workspace if it has the expected data shape, then an explicit user/host-tool path. Do not hardcode personal absolute paths.

- Точка входа: `{data-repo}/AGENTS.md`
- Базовые правила: `{data-repo}/BASE.md`
- Task-folders: `{data-repo}/work-artifacts/`
- Summary workflow: `skills/summary/references/workflow.md` in the HARE Trail system repo
- Durable notes: `{data-repo}/notes/`

## Когда использовать

Используй этот workflow, когда пользователь хочет не просто summary источников, а полноценное исследование:

- есть вопрос, который будет меняться и уточняться;
- нужны гипотезы, проверки и развилки;
- нужно собирать не только документы, но и сам ход мысли;
- нужны prompts для дальнейшего deep research;
- задача может идти через несколько репозиториев, разговоров и внешних материалов.

## Результат

На выходе должен быть task-folder с минимумом:

```text
{task-folder}/
  README.md
  tracker.md
  journal.md
  sources/
  file-summaries/
```

`prompts/` добавлять только когда пользователь просит подготовить их для внешних исследовательских ИИ или это явно входит в requested output.

Default placement:

- По умолчанию новый research artifact создаётся в `{data-repo}/work-artifacts/`.
- Если пользователь явно просит создать artifact в текущем workspace/repo, использовать указанное место и зафиксировать это в `README.md`.
- Если research folder создан в `{data-repo}` из контекста внешнего рабочего repo и к нему вероятно будут возвращаться в следующих сессиях, предложить пользователю создать `ln -s` в текущем repo для удобного доступа. Не создавать symlink молча.
- Новый значимый research artifact должен быть local git repo по умолчанию, если он не tiny/throwaway. Если repo author identity неоднозначна, спросить пользователя или применить local data config.
- Если research folder является git repo, новые файлы, явно относящиеся к текущему исследованию, нужно добавить в index (`git add <files>`) до завершения работы; unrelated user changes не stage-ить.

## 1. Собрать контекст

1. Если есть входной пакет документов, прогнать логикой `summary`.
2. Если нет документов, но есть вопрос, создать task-folder и записать стартовый контекст вручную.
3. Если стартовым материалом служит разговор с ИИ, большой prompt или экспорт внешнего чата, сохранить raw artifact в `sources/` и зафиксировать это в `README.md`.
4. Если вопрос сильно двусмысленный и без уточнения исследование получится мусорным, задать короткие вопросы пользователю.

## 2. Зафиксировать стартовое состояние

В `tracker.md` записать:

- формулировку вопроса сейчас;
- зачем это исследование;
- ограничения;
- текущую рабочую гипотезу;
- что нужно получить на выходе.

## 3. Составить исследовательский план

План должен быть коротким и проверяемым:

- какие направления проверить;
- какие данные/источники нужны;
- какие гипотезы уязвимы;
- какие вопросы надо задать пользователю;
- какие внешние исследовательские ИИ можно использовать позже.

## 4. Вести `journal.md`

`journal.md` — append-only.

Фиксировать:

- как менялся вопрос;
- что предполагал пользователь;
- что предполагал агент;
- что проверили;
- что оказалось ложным;
- что оказалось сильным контрпримером;
- как изменилось понимание;
- важные цитаты пользователя и ИИ.

## 5. Обязательные секции

### В `tracker.md`

- Current question
- Current hypothesis
- What contradicts the current model
- Open questions
- Next step

### В `journal.md`

- timestamp
- question at this moment
- attempt
- evidence
- result
- interpretation

## 6. Prompts

Если исследование стоит продолжить внешними системами, создавать prompts в `prompts/` только когда:

- пользователь прямо попросил prompt-файлы;
- пользователь просит research packet для внешней системы;
- в текущем task-folder prompts уже существуют как явный тип артефакта.

Типичные prompts:

- `deep-research-prompt.md`
- `compare-approaches-prompt.md`
- `critique-current-model-prompt.md`
- `extract-durable-notes-prompt.md`

Языковое правило для prompt-файлов:

- без отдельного указания пользователя reusable prompts делать на языке пользователя текущего диалога;
- если внешний инструмент или целевая аудитория явно требуют другого языка, сначала уточнить это у пользователя или сделать параллельные версии с явной маркировкой (`-ru`, `-en`);
- не оставлять canonical prompt-файл на "случайно выбранном" языке без маркировки.

## 7. Переход в durable notes и debriefs

После значимого этапа полезно решить:

- что надо вынести в `notes/` как долговечную заметку;
- что надо вынести в `session-debriefs/` как debrief по ошибке или ложной гипотезе.
- что надо сохранить как reusable prompt или summary для переключения между моделями и следующими сессиями.

Не путать эти слои:

- research = ход мысли и исследование;
- debrief = уроки и ошибки;
- notes = устойчивое знание.
