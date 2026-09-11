# Design: ui-modernization

## Context

Текущий фронтенд — голый scaffold: пустой `app/assets/stylesheets/application.css`, отсутствие навигации, список задач — таблица, главная страница — заглушка. Стек Hotwire (Turbo + Stimulus) подключён, но не используется. Проект работает без Node.js/npm — JS подключается через importmap, ассеты через Propshaft. Вся логика задач вынесена в интеракторы (`Tasks::Creator`, `Tasks::Updater`, `Tasks::Destroyer`), модель `Task` имеет enum статусов `todo`/`in_progress`/`done` и приоритет (integer, по умолчанию 0). Существующие request-спеки ассертируют редиректы (POST/PATCH/DELETE) — их HTML-поведение сохраняется.

Мотивация и «что» — см. `proposal.md`; поведенческие требования — см. delta-спеки.

## Goals / Non-Goals

**Goals:**
- Внедрить Tailwind CSS через официальный гем (без Node.js).
- Единый лейаут с навигацией, стилизованные flash с автоскрытием.
- Дашборд со статистикой на главной.
- Карточки задач вместо таблицы с цветовой индикацией статуса/приоритета.
- Модальные формы создания/редактирования (Turbo Frames) и обновление списка через Turbo Streams.
- Интерактивная смена статуса из списка.
- Анимации появления и hover-переходы.

**Non-Goals:**
- Drag-and-drop (HTML5 DnD API) — см. D4, вынесено из скоупа как более рискованная и менее доступная альтернатива.
- Переход на SPA/React/Vue.
- Изменения схемы БД, моделей, интеракторов, валидаций.
- Анимация исчезновения карточки на удаление — потенциальное улучшение, см. Open Questions.

## Decisions

### D1. Tailwind CSS через гем `tailwindcss-rails`
Проект не использует Node/npm (importmap). Гем поставляет standalone-бинарник Tailwind, скомпилированный под платформу, — Node не нужен. Установка: `bin/rails tailwindcss:install` — создаёт `app/assets/tailwind/application.css` (исходник с `@tailwind`-директивами), `config/tailwind.config.js`, выходной `app/assets/builds/tailwind.css` (подключается через Propshaft) и `bin/dev` для watch-режима.

- *Рассмотрено:* подключение Tailwind через CDN-скрипт — отклонено: нет сборки, FOUC, не подходит для продакшена.
- *Рассмотрено:* чистый CSS/Sass — отклонено: больше ручной работы, ниже консистентность, дольше.

### D2. Модалки на Turbo Frames (без JS-рендера)
Общий контейнер `<turbo_frame_tag id: "task_modal">` размещается на странице списка задач. Ссылки «Новая задача» и «Редактировать» указывают на `new_task_path` / `edit_task_path` с `data: { turbo_frame: "task_modal" }`. Шаблоны `new.html.erb` / `edit.html.erb` оборачивают партиал `_form.html.erb` в `<turbo_frame_tag id: "task_modal">`. При frame-запросе Turbo извлекает из ответа только нужный frame — поэтому одни и те же шаблоны работают и как полноценные страницы (прямой переход на `/tasks/new`), и как содержимое модалки.

Оверлей и плавное открытие/закрытие — Stimulus-контроллер `modal` (закрытие по «Отмена», клику по фону, клавише Esc).

- *Рассмотрено:* рендер модалок чистым JS с шаблонизацией — отклонено: дублирует серверные формы, ломает SSR/Hotwire-подход.
- *Рассмотрено:* `dialog` + turbo-frame — оставлено как вариант реализации контроллера, суть не меняет.

### D3. Обновление списка через Turbo Streams
Контроллер задач начинает отвечать на `turbo_stream` (`respond_to`), HTML-ветка сохраняет текущие редиректы (существующие спеки не ломаются):

- `create`: `turbo_stream.append` новой карточки в `#tasks_list` + очистка модалки (`turbo_stream.update "task_modal", ""`) + flash-сообщение (через `flash.now`, т.к. редиректа нет).
- `update` из модалки: `turbo_stream.replace` карточки + очистка модалки + flash.
- `destroy`: `turbo_stream.remove` карточки + flash.
- `update_status`: `turbo_stream.replace` карточки.
- Ошибка валидации: `turbo_stream` с `status: :unprocessable_content` и ре-рендером формы внутри модалки (`turbo_stream.replace "task_modal"`), HTML-ветка — `render :new/:edit, status: :unprocessable_content`.

Партиал `_task_card.html.erb` — единый источник разметки карточки (используется в списке, `append`, `replace`).

### D4. Интерактивная смена статуса — select + Turbo, без drag-and-drop
На каждой карточке — `<select>` статуса внутри маленькой `<form>` с Stimulus-контроллером `status`, который вызывает `form.requestSubmit()` при изменении. PATCH уходит на выделенный маршрут `PATCH /tasks/:id/status` → экшен `update_status`, вызывающий `Tasks::Updater` с `{ status: ... }` и отвечающий `turbo_stream.replace` карточки.

- *Почему отдельный экшен, а не общий `update`:* одна ответственность, не трогает остальные поля, легко тестировать.
- *Рассмотрено:* drag-and-drop через HTML5 DnD API + Stimulus — отклонено: заметно сложнее (drop-зоны, подсветка, координаты), плохо на совместимость и мобильные устройства, не закрыт сценарий из спека. Текст спека («пользователь выбирает новый статус») соответствует select-подходу.

### D5. Дашборд на главной
`HomeController#index` собирает статистику простыми запросами (без изменения схемы):
- `Task.group(:status).count` + добивка нулями отсутствующих статусов;
- `Task.count`;
- прогресс = `done / total * 100` (0 при отсутствии задач);
- `Task.order(created_at: :desc).limit(5)` — последние задачи.

Разметка: карточки-счётчики, прогресс-бар (Tailwind `w-[N%]`), список последних задач со ссылкой на полный список.

### D6. Flash-сообщения
Разметка остаётся в лейауте, стилизуется по типу (`notice` — emerald, `alert` — red). Stimulus-контроллер `flash`: платное автоскрытие через ~4 c c fade-анимацией, кнопка закрытия.

### D7. Стили, цвета и анимации
- Хелперы возвращают Tailwind-классы: badge статуса (`todo`=slate, `in_progress`=blue, `done`=emerald); индикатор приоритета (0 — серый, 1–2 — зелёный, 3 — янтарный, 4–5 — красный).
- Кастомные keyframes `fade-in`/`fade-out` — через `theme.extend.animation` в `config/tailwind.config.js` (или `@keyframes` в `app/assets/tailwind/application.css`).
- Hover/переходы — утилиты `transition` + `hover:`.

## Risks / Trade-offs

- [Standalone-бинарник Tailwind привязан к платформе] → гем использует platform-specific под-гемы; это естественно для Debian-машины разработчика; для деплоя/Kamal — `bin/rails assets:precompile` собирает CSS скомпилированным бинарником той же платформы, следить за arch контейнера.
- [Flash не появится при turbo_stream-ответе без редиректа] → использовать `flash.now` и рендерить блок flash в turbo-stream шаблонах.
- [Добавление карточки через append при активных фильтрах: задача может не соответствовать фильтру и всё равно появиться] → приемлемо как визуальный quirk; при необходимости позже — отключать append при активных фильтрах (Open Question на доработку после релиза).
- [Конфликт frame-контейнера `task_modal` при параллельных модалках] → один контейнер на страницу, повторный клик просто перезагружает его содержимое.
- [Существующие request-спеки ассертируют редиректы] → HTML-ветка `respond_to` сохраняет редиректы; спеки не меняются, добавляются новые на turbo_stream.

## Migration Plan

- Единый деплой без схемных миграций.
- Установка Tailwind добавляет в Gemfile.lock платформенные под-гемы — обычный `bundle install`.
- Откат: revert коммита; `app/assets/builds/tailwind.css` и изменения CSS в шаблонах уйдут вместе с ним.
- Dev-процесс: `bin/dev` (Procfile: web + tailwind watch). Продакшен-сборка — через `assets:precompile`.

## Open Questions

- Нужна ли анимация исчезновения карточки при удалении (fade-out перед `turbo_stream.remove`)? Решаемо позже без изменения спеков — добавить контроллер/класс на `turbo:before-render`.
- Отключать ли `turbo_stream.append` при активных фильтрах на индексе? Кандидат на отдельное улучшение после релиза.