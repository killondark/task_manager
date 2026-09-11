## 1. Миграция и модель

- [x] 1.1 Сгенерировать миграцию для таблицы `tasks` с колонками: `title` (string, null: false), `description` (text), `status` (string, null: false, default: "todo"), `priority` (integer, null: false, default: 0), `deadline` (datetime), timestamps — проверить: `bin/rails db:migrate` проходит, таблица появляется в `db/schema.rb`
- [x] 1.2 Создать модель `app/models/task.rb` с валидациями (presence :title, inclusion :status, custom :deadline_not_in_the_past) и enum `status` — проверить: `bin/rails console` и `Task.new` работает как ожидается
- [x] 1.3 Написать model spec (`spec/models/task_spec.rb`): валидация наличия title, enum status с default "todo", валидация дедлайна (не в прошлом), недопустимый статус — проверить: `bundle exec rspec spec/models/task_spec.rb` все тесты зелёные

## 2. Контроллер и маршруты

- [x] 2.1 Добавить `resources :tasks` в `config/routes.rb` — проверить: `bin/rails routes | grep task` показывает все 7 RESTful маршрутов
- [x] 2.2 Создать `TasksController` с actions: index, show, new, create, edit, update, destroy, private метод `set_task` и `task_params` — проверить: контроллер существует, actions определены
- [x] 2.3 Реализовать `index` с фильтрами: scope `by_status` и `by_priority` в модели, применение в controller — проверить: GET `/tasks?status=todo` возвращает 200

## 3. Представления (View)

- [x] 3.1 Создать `_form.html.erb` с полями: title, description, status (select), priority (number), deadline (datetime_local_field) — проверить: шаблон рендерится без ошибок
- [x] 3.2 Создать `index.html.erb`: список задач, ссылки на show/edit, ссылка "Новая задача", форма фильтров (status select + priority input) — проверить: GET `/tasks` отдаёт 200 со списком
- [x] 3.3 Создать `show.html.erb`: отображение всех полей задачи, ссылки edit/destroy — проверить: GET `/tasks/:id` отдаёт 200
- [x] 3.4 Создать `new.html.erb` и `edit.html.erb`: рендерят `_form` — проверить: GET `/tasks/new` и GET `/tasks/:id/edit` отдают 200
- [x] 3.5 Добавить flash-сообщения в `app/views/layouts/application.html.erb` — проверить: при create/update/destroy отображается flash notice/alert

## 4. Тесты (Request Specs)

- [x] 4.1 Написать request spec для CRUD (`spec/requests/tasks_spec.rb`): GET /tasks (index), GET /tasks/:id (show), GET /tasks/new (new), POST /tasks (create success + failure), GET /tasks/:id/edit (edit), PATCH /tasks/:id (update success + failure), DELETE /tasks/:id (destroy) — проверить: `bundle exec rspec spec/requests/tasks_spec.rb` зелёные
- [x] 4.2 Написать request spec для фильтров: GET `/tasks?status=in_progress` возвращает отфильтрованный список, GET `/tasks?priority=5` — проверить: тесты фильтров зелёные

## 5. Финальная проверка

- [x] 5.1 Запустить `bundle exec rspec` — все тесты (model + request) проходят без ошибок
- [x] 5.2 Запустить `bin/rails server`, вручную проверить создание/редактирование/удаление задачи через браузер, затем остановить сервер
