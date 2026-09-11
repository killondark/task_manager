## 1. Зависимости

- [x] 1.1 Добавить `gem 'dry-monads'` и `gem 'dry-validation', '~> 1.8'` в Gemfile и выполнить `bundle install`; проверить, что установка завершилась без ошибок (`bundle list | grep dry`)
- [x] 1.2 Проверить загрузку гемов в рантайме: `bin/rails runner 'p Dry::Monads::Success(:ok); p Dry::Validation::Contract'` отрабатывает без ошибок

## 2. Базовый класс интеракторов

- [x] 2.1 Создать `app/interactors/application_interactor.rb` с `ApplicationInteractor` и вложенным `BaseContract` по образцу broadcaster (dry-monads результат, do-нотация, `extend Dry::Initializer`, `validate_contract`, `process_error` с `Rails.logger`); проверить загрузку класса через `bin/rails runner 'p ApplicationInteractor.call'`

## 3. Интеракторы задач

- [x] 3.1 Реализовать `app/interactors/tasks/creator.rb`: контракт `required(:task_params).value(:hash)`, создание `Task.new(task_params)`; при успехе `Success(task)`, при ошибке валидации `Failure(task)`; проверить юнит-спеками из раздела 5
- [x] 3.2 Реализовать `app/interactors/tasks/updater.rb`: контракт `required(:task).filled(type?: Task)` + `required(:task_params).value(:hash)`, обновление `task.update(task_params)`; `Success(task)` / `Failure(task)`; проверить юнит-спеками из раздела 5
- [x] 3.3 Реализовать `app/interactors/tasks/destroyer.rb`: контракт `required(:task).filled(type?: Task)`, удаление через `task.destroy`; `Success(task)`; проверить юнит-спеками из раздела 5

## 4. Рефакторинг контроллера

- [x] 4.1 Заменить `create` на вызов `Tasks::Creator.call(task_params: task_params.to_h)` с ветвлением по `success?`: редирект на задачу или `@task = result.failure` + `render :new, status: :unprocessable_content`; проверка — специ `tasks_spec.rb` на создание
- [x] 4.2 Заменить `update` на вызов `Tasks::Updater.call(task: @task, task_params: task_params.to_h)` с ветвлением по `success?`: редирект на задачу или `@task = result.failure` + `render :edit, status: :unprocessable_content`; проверка — специ `tasks_spec.rb` на обновление
- [x] 4.3 Заменить `destroy` на вызов `Tasks::Destroyer.call(task: @task)` с последующим редиректом на список; проверка — специ `tasks_spec.rb` на удаление

## 5. Тесты интеракторов

- [x] 5.1 Написать `spec/interactors/tasks/creator_spec.rb`: успешное создание (`Success(task)`, задача в БД), ошибка AR-валидации (`Failure(task)` с `errors`, задача не сохранена), пустой хэш параметров возвращает `Failure` и не создаёт задачу; проверить `bundle exec rspec spec/interactors/tasks/creator_spec.rb`
- [x] 5.2 Написать `spec/interactors/tasks/updater_spec.rb`: успешное обновление (`Success(task)`), ошибка AR-валидации (`Failure(task)`, изменения не применены), нарушение контракта (не хэш параметров) возвращает `Failure`; проверить `bundle exec rspec spec/interactors/tasks/updater_spec.rb`
- [x] 5.3 Написать `spec/interactors/tasks/destroyer_spec.rb`: успешное удаление (`Success(task)`, задача удалена из БД), нарушение контракта (не объект `Task`) возвращает `Failure`; проверить `bundle exec rspec spec/interactors/tasks/destroyer_spec.rb`
- [x] 5.4 Прогнать весь набор: `bundle exec rspec` — все существующие и новые спеки зелёные; дополнительно `bundle exec rubocop` без новых нарушений