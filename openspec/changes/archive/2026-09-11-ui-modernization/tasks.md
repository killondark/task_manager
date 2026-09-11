# Tasks: ui-modernization

## 1. Подключение Tailwind CSS

- [x] 1.1 Добавить гем `tailwindcss-rails` в Gemfile, выполнить `bundle install` и `bin/rails tailwindcss:install`; verify команда `bin/rails tailwindcss:build` собирает CSS в `app/assets/builds/tailwind.css` без ошибок
- [x] 1.2 Настроить контент-паттерны и `theme.extend.animation` с keyframes `fade-in`/`fade-out`; verify собранный CSS содержит соответствующие утилиты при использовании в шаблонах
- [x] 1.3 Подключить собранный CSS через лейаут (`stylesheet_link_tag "app"`, при необходимости добавить `app/assets/builds` в Propshaft-пути); verify страница приложения отвечает HTTP 200 и отдаёт стили (запрос в браузере не даёт 404 на CSS)

## 2. Лейаут, навигация и flash-сообщения

- [x] 2.1 Добавить в `app/views/layouts/application.html.erb` навигацию со ссылками «Главная» и «Задачи» и подсветкой активного пункта через `current_page?`; verify при открытии любой страницы в DOM присутствует навигация и активный пункт (request-спека или ручная проверка)
- [x] 2.2 Стилизовать flash-сообщения по типу (`notice`/`alert`) через Tailwind-классы, добавить кнопку закрытия; verify в разметке flash-блок содержит классы нужного типа (request-спека отображает flash после создания задачи)
- [x] 2.3 Создать Stimulus-контроллер `flash_controller.js`: автоскрытие сообщения через ~4 секунды с fade-анимацией и закрытие по кнопке; verify ручная проверка в браузере: сообщение исчезает через несколько секунд

## 3. Дашборд на главной странице

- [x] 3.1 Расширить `HomeController#index` выборкой статистики: счётчики по статусам (`Task.group(:status).count` с добивкой нулей), общее количество, прогресс `done/total`, последние 5 задач; verify request-спека `home_spec.rb` проверяет наличие счётчиков и корректность при пустой базе
- [x] 3.2 Сверстать `app/views/home/index.html.erb`: карточки-счётчики по статусам, прогресс-бар с процентом, список последних задач и ссылка на полный список; verify request-спека проверяет, что на главной отображаются заголовки последних задач и ссылка на список задач

## 4. Карточки задач вместо таблицы

- [x] 4.1 Создать партиал `app/views/tasks/_task_card.html.erb`: заголовок-ссылка, badge статуса, индикатор приоритета, дедлайн, кнопки «Редактировать»/«Удалить»; verify ручная проверка: карточка отображает все поля задачи
- [x] 4.2 Добавить хелперы в `app/helpers/tasks_helper.rb`, возвращающие Tailwind-классы для badge статуса (`todo`=slate, `in_progress`=blue, `done`=emerald) и индикатора приоритета (0=серый, 1–2=зелёный, 3=янтарный, 4–5=красный); verify замена статуса/приоритета задачи меняет классы в разметке (request-спека)
- [x] 4.3 Заменить `<table>` на grid из `_task_card` на странице `tasks/index.html.erb`, сохранив форму фильтрации; verify request-спека `tasks_spec.rb`: страница `/tasks` содержит заголовок задачи, а фильтры по статусу/приоритету продолжают работать (существующий `tasks_filters_spec.rb` зелёный)

## 5. Интерактивная смена статуса

- [x] 5.1 Добавить маршрут `patch :status` (member) для `resources :tasks` и экшен `TasksController#update_status`, использующий `Tasks::Updater` с `{ status: ... }` и отвечающий `turbo_stream.replace` карточки; verify request-спека: `PATCH /tasks/:id/status` меняет статус в БД и возвращает turbo_stream с обновлённой карточкой
- [x] 5.2 Добавить на карточку `<form>` со `<select>` статуса и Stimulus-контроллер `status_controller.js`, вызывающий `requestSubmit()` при изменении; verify ручная проверка в браузере: выбор статуса обновляет карточку без перезагрузки страницы

## 6. Модальные формы (Turbo Frames) и Turbo Streams

- [x] 6.1 Добавить контейнер `<turbo_frame_tag id: "task_modal">` на страницу списка и `data: { turbo_frame: "task_modal" }` на ссылки «Новая задача» и «Редактировать»; verify в разметке список содержит frame-контейнер, а ссылки — атрибут `data-turbo-frame`
- [x] 6.2 Обернуть `_form.html.erb` в `<turbo_frame_tag id: "task_modal">` внутри `new.html.erb` и `edit.html.erb`; verify request-спека: прямое открытие `/tasks/new` и `/tasks/:id/edit` по-прежнему возвращает страницу с формой (ок)
- [x] 6.3 Создать Stimulus-контроллер `modal_controller.js`: плавное открытие, закрытие по клику на фон, клавише Esc и кнопке «Отмена»; verify ручная проверка: модалка открывается из списка и закрывается без отправки данных
- [x] 6.4 Добавить `respond_to` в `create`/`update`/`destroy` и turbo_stream-шаблоны `create.turbo_stream.erb` (append карточки + очистка модалки + flash через `flash.now`), `update.turbo_stream.erb` (replace карточки + очистка модалки + flash), `destroy.turbo_stream.erb` (remove карточки + flash); verify request-спеки: POST c `Accept: turbo_stream` создаёт задачу и возвращает append, DELETE — remove, существующие HTML-спеки на редиректы остаются зелёными
- [x] 6.5 Обработать ошибку валидации в modal-формах: turbo_stream-ветка с `status: :unprocessable_content` и ре-рендером формы в `task_modal`; verify request-спека: POST/PATCH с некорректными данными в формате turbo_stream возвращает 422 и форму с ошибками

## 7. Анимации

- [x] 7.1 Применить анимации появления (`animate-fade-in`) к карточкам задач и модальному оверлею, hover-переходы к карточкам и кнопкам через `transition` + `hover:`; verify ручная проверка в браузере: карточки появляются плавно, hover-эффекты работают

## 8. Финальная проверка

- [x] 8.1 Добавить/обновить request-спеки для новых turbo_stream-ответов, `update_status`, статистики на главной и убедиться, что существующие спеки (включая `tasks_filters_spec.rb`) не сломаны; verify `bundle exec rspec` проходит полностью
- [x] 8.2 Проверить стиль кода: verify `bin/rubocop` и (при доступности) сборка ассетов `bin/rails assets:precompile` выполняются без ошибок