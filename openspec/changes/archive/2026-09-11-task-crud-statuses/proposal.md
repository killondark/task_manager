## Why

Приложение пока не имеет доменной модели — даже пустой каркас. Первый пользовательский сценарий — создание, редактирование и отслеживание задач с жизненным циклом статусов. Без этого нет функционального ядра, вокруг которого строятся фильтры, дедлайны и приоритеты.

## What Changes

- Новая модель `Task` с полями: `title` (string, presence), `description` (text, optional), `status` (enum: todo, in_progress, done; default: todo), `priority` (integer, по умолчанию 0), `deadline` (datetime, optional, валидация — не в прошлом)
- RESTful CRUD для задач: `TasksController` (index, show, new, create, edit, update, destroy)
- Маршруты `resources :tasks`
- Валидация модели: title обязателен, статус — допустимое значение, дедлайн не раньше текущего момента
- Фильтрация по статусу и приоритету на странице index (параметры `status` и `priority` в query string)
- Flash-сообщения при успешных/неуспешных действиях
- RSpec-тесты: model specs (валидации, переходы статусов), request specs (CRUD-маршруты, фильтры)

## Capabilities

### New Capabilities
- `task-crud`: CRUD-операции над задачами с валидацией, статусами жизненного цикла и фильтрацией

### Modified Capabilities
_(нет изменений в существующих спеках)_

## Impact

- **Код**: новые файлы в `app/models/`, `app/controllers/`, `app/views/tasks/`, `db/migrate/`
- **Маршруты**: добавление `resources :tasks` в `config/routes.rb`
- **База данных**: миграция для таблицы `tasks`
- **Тесты**: новые файлы в `spec/models/`, `spec/requests/`
- **Зависимости**: без изменений (RSpec уже подключён)
