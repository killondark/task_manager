## Context

Текущее состояние: вся бизнес-логика CRUD задач находится в `TasksController` (создание, обновление, удаление через `Task.new`, `task.save`, `task.update`, `task.destroy`) и в модели `Task` (AR-валидации: заголовок, статус, дедлайн; скоупы фильтрации). Приложение full-stack (server-rendered ERB + Turbo), не API. Мотивация — см. proposal.md (Why).

Целевой паттерн взят из проекта broadcaster (`ApplicationInteractor` + контракты `Dry::Validation::Contract` + интеракторы, возвращающие `Success`/`Failure`).

## Goals / Non-Goals

**Goals:**
- Вынести создание, обновление и удаление задачи из контроллера в интеракторы.
- Ввести единообразную валидацию входных данных интеракторов через dry-validation контракты и единый результат `Success`/`Failure`.
- Сохранить модель `Task` как единственный источник истины для валидации атрибутов.
- Сохранить наблюдаемое поведение `task-crud` без изменений.

**Non-Goals:**
- Не менять действия `index`, `new`, `edit` и представления.
- Не выносить фильтрацию списка (`by_status`/`by_priority`) в интеракторы.
- Не менять модель `Task`, скоупы и схему БД.
- Не добавлять авторизацию, сериализацию в JSON или API-слой.

## Decisions

### 1. Состав гемов
Добавляем `gem 'dry-monads'` и `gem 'dry-validation', '~> 1.8'`. `dry-initializer` (нужен для `extend Dry::Initializer` в базовом классе) поставляется транзитивно как зависимость `dry-validation`, что уже работает в проекте-образце без явного объявления.
*Альтернатива:* объявить `dry-initializer` явно — не требуется, добавляет шум в Gemfile.

### 2. Базовый класс `ApplicationInteractor`
`app/interactors/application_interactor.rb` зеркалит класс из broadcaster:
- `include Dry::Monads[:result, :do, :maybe, :try]`, `include Dry::Monads::Do.for(:call)`, `extend Dry::Initializer`;
- вложенный `BaseContract < Dry::Validation::Contract`;
- `self.call(params = {})` → `new(**params).call`;
- приватные `validate_contract(contract, params, **contract_options)` и `process_error`.

Адаптация к нашему стеку: убираем Sentinel/`ErrorHandler` — при `StandardError` логируем через `Rails.logger`, перевыбрасываем в `test` окружении, иначе возвращаем `Failure(e)`.

**Отклонение от образца под Ruby 3 (2.7 → 3.3):** в broadcaster `self.call` использует `new(params)`, а вызовы `validate_contract` передают параметры keyword-аргументами — это работает на Ruby 2.7, где keyword-аргументы автоматически сливались в позиционный хэш. На Ruby 3 dry-initializer игнорирует позиционный хэш как опции (`initialize(*args, **kwargs)`), а keyword-аргументы уходят в `**contract_options`, оставляя `params` пустым. Поэтому в нашей реализации `self.call` пересылает `new(**params)`, а контракты вызываются с явным позиционным хэшем: `validate_contract(Contract, { task_params: task_params })`. Внешний контракт вызова интеракторов (`Creator.call(task_params: ...)`) при этом не меняется.

### 3. Значение Failure — объект задачи
В отличие от broadcaster (там `Failure(additional_file.errors.messages)` для API), интеракторы возвращают `Failure(task)` — ту самую (несохранённую/необновлённую) задачу с `errors`. Причина: формам ERB нужен объект, несущий ошибки; контроллер делает `@task = result.failure` и рендерит форму повторно.
*Альтернатива:* возвращать хэш ошибок — отклонена, так как для повторного рендера формы пришлось бы реконструировать `@task ` и переносить ошибки.

### 4. Сигнатуры интеракторов и контракты
- `Tasks::Creator.call(task_params:)` — контракт: `required(:task_params).value(:hash)`, внутри `Task.new(task_params)` → `Success(task)` если сохранён, иначе `Failure(task)`.
- `Tasks::Updater.call(task:, task_params:)` — контракт: `required(:task).filled(type?: Task)`, `required(:task_params).value(:hash)`, внутри `task.update(task_params)` → `Success(task)` / `Failure(task)`.
- `Tasks::Destroyer.call(task:)` — контракт: `required(:task).filled(type?: Task)`, внутри `task.destroy` → `Success(task)`.

Контракты проверяют только форму входа (тип объекта и наличие хэша параметров). Валидация атрибутов остаётся в модели `Task` — это единственный источник правил (присутствие заголовка, включение статуса, дедлайн не в прошлом).
*Альтернатива:* продублировать правила атрибутов в dry-контрактах — отклонена: двойное обслуживание и риск расхождения с AR-валидациями.

### 5. Пустые параметры без явного guard
В примере есть ранний `return Failure('empty params')`, т.к. `additional_files_params` может быть пустым при валидном для контракта хэше. У нас заголовок обязателен, поэтому пустой хэш параметров провалит AR-валидацию и вернёт `Failure(task)` естественным образом.
*Альтернатива:* буквальный guard из примера — отклонён: вернул бы строку вместо задачи и сломал бы единообразный рендер формы в контроллере.

### 6. Рефакторинг `TasksController`
- `create`: `Tasks::Creator.call(task_params: task_params.to_h)` → при успехе `redirect_to result.value!`; при ошибке `@task = result.failure` и `render :new, status: :unprocessable_content`.
- `update`: `Tasks::Updater.call(task: @task, task_params: task_params.to_h)` → при успехе `redirect_to result.value!`; при ошибке `@task = result.failure` и `render :edit, status: :unprocessable_content`.
- `destroy`: `Tasks::Destroyer.call(task: @task)` → `redirect_to tasks_url`.
- `index`, `new`, `edit`, `set_task`, `task_params` и статус-коды ответов не меняются.

### 7. Тесты
Покрываем интеракторы юнит-спеками `spec/interactors/tasks/{creator,updater,destroyer}_spec.rb`: успешные пути, ошибки AR-валидации, нарушение контрактов. Существующие request-спеки (`tasks_spec.rb`, `tasks_filters_spec.rb`) остаются без изменений и должны продолжать проходить.

## Risks / Trade-offs

- [Новые зависимости `dry-monads` / `dry-validation`] → лёгкие, проверенные библиотеки того же стека (используются в broadcaster); зафиксируем `~> 1.8` для `dry-validation`.
- [Контракты валидируют только форму входа, не атрибуты] → ошибки атрибутов приходят из AR; явно зафиксировано в спецификации, чтобы не воспринималось как разрыв.
- [Failure несёт AR-объект вместо хэша/строки] → вызывающий слой обязан работать с задачей; это описано в спеках `task-interactors`.
- [Действие `destroy` игнорирует результат интерактора] → удаление идемпотентно по отношению к пользователю; при необходимости можно добавить проверку результата позже без изменения контракта интерфейса.

## Migration Plan

1. Добавить гемы в Gemfile и выполнить `bundle install`.
2. Добавить `app/interactors/application_interactor.rb`.
3. Добавить интеракторы `Tasks::Creator`, `Tasks::Updater`, `Tasks::Destroyer`.
4. Отрефакторить `TasksController`.
5. Добавить спеки интеракторов и прогнать весь набор (`bin/rspec`).
6. Откат: рефакторинг аддитивен — достаточно вернуть прежнюю реализацию контроллера; БД и миграции не затронуты.

## Open Questions

Отсутствуют.