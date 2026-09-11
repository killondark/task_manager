class HomeController < ApplicationController
  def index
    @status_counts = Task.group(:status).count
    @total_tasks = Task.count
    @progress_percent = progress_percent
    @recent_tasks = Task.order(created_at: :desc).limit(5)
  end

  private

  def progress_percent
    return 0 if @total_tasks.zero?

    (@status_counts["done"].to_i * 100.0 / @total_tasks).round
  end
end
