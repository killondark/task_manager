# Task Manager

Менеджер задач на Ruby, построенный с использованием спецификаций OpenSpec.

Стек: Ruby 3.3.1, Rails, SQLite, Hotwire (Turbo + Stimulus), Tailwind CSS, RSpec.

## Возможности

- Полный CRUD задач
- Статусы: todo, in_progress, done
- Фильтрация по статусу и приоритету
- Дашборд со счётчиками и прогрессом
- Модальные формы через Turbo Frame и обновление списка через Turbo Stream
- Бизнес-логика в интеракторах (dry-* gems)

## Запуск

```sh
bin/setup
bin/dev
```

Тесты:

```sh
rspec
```

## Работа по OpenSpec

Проект развивается через спецификации. `openspec/specs/` — источник правды: каждый аспект поведения описан требованиями в capability-спеках.

Изменения вносятся через процесс change:

1. `opsx-explore` — исследовать задачу или уточнить требования
2. `opsx-propose` — сформировать предложение (proposal, design, задачи)
3. `opsx-apply` — реализовать по задачам из плана
4. `opsx-sync` — синхронизировать delta-спеки с основными
5. `opsx-archive` — заархивировать завершённый change