## Context

Приложение — пустой каркас Rails 8 с Hotwire и RSpec (см. archived change `bootstrap-rails-app`). Доменная модель отсутствует. Требования описаны в `specs/task-crud/spec.md`.

## Goals / Non-Goals

**Goals:**
- Минимальная, идиоматичная реализация CRUD для задач в Rails-стиле
- Валидация на уровне модели (presence, inclusion, custom deadline)
- Фильтрация через scope-методы модели, передаваемые через query string
- Полный набор RSpec-тестов (model + request)

**Non-Goals:**
- Пагинация / сортировка (отдельный change)
- AJAX / Turbo Streams для динамических обновлений — работаем через стандартный Turbo Drive (редиректы)
- REST API — только full-stack ERB
- Аутентификация / authorization
- Связи между задачами (подзадачи, зависимости)

## Decisions

**1. Хранение статуса: строковый enum через Rails 7+ `enum` с mapping**

```ruby
enum :status, { todo: "todo", in_progress: "in_progress", done: "done" }, default: "todo"
```

- *Почему не integer enum*: строковый вариант читаем в БД и логах, не требует маппинга при чтении
- *Альтернатива, отклонена*: отдельная таблица статусов — избыточно для трёх значений

**2. Валидация дедлайна: custom validator в модели**

```ruby
validate :deadline_not_in_the_past

def deadline_not_in_the_past
  return if deadline.blank?
  errors.add(:deadline, "не может быть в прошлом") if deadline < Time.current
end
```

- *Почему не `validates :deadline, timeliness: { after: -> { Time.current } }`*: не требует доп. гема (validates_timeliness), работает прозрачно
- *Альтернатива, отклонена*: валидация в контроллере — нарушает принцип толстых моделей

**3. Фильтрация: scope-методы модели, активируемые через `TasksController#index`**

```ruby
scope :by_status, ->(status) { where(status: status) if status.present? }
scope :by_priority, ->(priority) { where(priority: priority) if priority.present? }
```

- *Почему не Ransack / QueryObject*: для двух фильтров scope'ы — простое и достаточное решение
- *Альтернатива, отклонена*: отдельный Form Object — premature abstraction для простого списка

**4. Формы: частичные шаблоны `_form.html.erb` для new и edit**

Общая форма в `_form.html.erb`, переиспользуемая в `new.html.erb` и `edit.html.erb`. Стандартный Rails-паттерн.

**5. Flash-сообщения: стандартный `flash[:notice]` / `flash[:alert]`**

Отображаются в `application.html.erb` через блок flash. Минимальная реализация.

**6. Тесты: model specs для валидаций, request specs для маршрутов и фильтров**

- Model specs: валидации, default values, enum
- Request specs: CRUD-операции (GET/POST/PATCH/DELETE), фильтры, flash-сообщения

## Risks / Trade-offs

- **SQLite и Time.current**: SQLite хранит datetime как текст. При валидации дедлайна `Time.current` корректно работает с timezone приложения. Риск: при ручном вводе в формах Rails преобразует строку в datetime через `Time.zone.parse` — убедиться, что форма использует `datetime_local_field`
- **Фильтры без пагинации**: при большом количестве задач index-страница будет отдавать все записи → пагинация запланирована в следующем change
- **Нет optimistic locking**: параллельное редактирование одной задачи —潜在ный race condition → не входит в scope этого изменения
