class Task < ApplicationRecord
  enum :status, { todo: "todo", in_progress: "in_progress", done: "done" }, default: "todo"

  validates :title, presence: true
  validates :status, inclusion: { in: statuses.keys }

  validate :deadline_not_in_the_past

  scope :by_status, ->(status) { where(status: status) if status.present? }
  scope :by_priority, ->(priority) { where(priority: priority) if priority.present? }

  private

  def deadline_not_in_the_past
    return if deadline.blank?

    errors.add(:deadline, "не может быть в прошлом") if deadline < Time.current
  end
end
