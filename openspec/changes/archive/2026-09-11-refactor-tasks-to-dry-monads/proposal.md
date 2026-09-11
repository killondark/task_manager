## Why

Бизнес-логика CRUD задач живёт прямо в контроллере `TasksController` и модели `Task` без выделенного слоя: нет единого способа валидации входных данных и обработки ошибок. Хочется внедрить проверенный паттерн интеракторов с гемами `dry-monads` и `dry-validation` (по образцу проекта broadcaster), чтобы перенести логику из контроллеров, сделать её переиспользуемой, тестируемой и единообразно обрабатывающей ошибки.

## What Changes

- Добавить в Gemfile гемы `dry-monads` и `dry-validation` (`dry-initializer` притянется транзитивно и станет доступен в рантайме, как в примере).
- Ввести базовый класс `ApplicationInteractor` с вложенным `BaseContract < Dry::Validation::Contract`, включающим dry-monads результат (`Success`/`Failure`), do-нотацию, `extend Dry::Initializer` и хелперы `validate_contract` / `process_error`.
- Вынести создание, обновление и удаление задачи из контроллера в интеракторы `Tasks::Creator`, `Tasks::Updater`, `Tasks::Destroyer`.
- Интеракторы валидируют входные параметры через dry-validation контракты, а валидации атрибутов остаются в модели `Task` (как в примере broadcaster).
- Интеракторы возвращают результат: `Success(task)` при успехе и `Failure(task)` при ошибке валидации — несохранённый объект задачи с `errors`, который контроллер передаёт в форму (адаптация под server-rendered ERB).
- `TasksController` использует интеракторы в действиях `create` / `update` / `destroy`; `index`, `new`, `edit` и модель `Task` не меняются.
- Добавить RSpec-тесты интеракторов; существующие request-спеки остаются зелёными.

## Capabilities

### New Capabilities
- `task-interactors`: слой интеракторов для операций над задачами (создание, обновление, удаление), которые валидируют входные данные через dry-validation контракты и возвращают результаты dry-monads.

### Modified Capabilities
- `task-crud`: требований не меняет — пользовательское поведение (формы, редиректы, сообщения об ошибках) остаётся прежним.

## Impact

- Зависимости: `Gemfile` / `Gemfile.lock` — новые гемы `dry-monads`, `dry-validation`.
- Новые файлы: `app/interactors/application_interactor.rb`, `app/interactors/tasks/creator.rb`, `app/interactors/tasks/updater.rb`, `app/interactors/tasks/destroyer.rb`, `spec/interactors/tasks/*_spec.rb`.
- Изменяемые файлы: `app/controllers/tasks_controller.rb`.
- Не меняются: модель `Task`, представления, маршруты, схема БД.