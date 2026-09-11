class TasksController < ApplicationController
  before_action :set_task, only: %i[show edit update destroy]

  def index
    @tasks = Task.by_status(params[:status]).by_priority(params[:priority])
  end

  def show
  end

  def new
    @task = Task.new
  end

  def create
    result = Tasks::Creator.call(task_params: task_params.to_h)

    if result.success?
      redirect_to result.value!, notice: "Задача создана."
    else
      @task = result.failure
      render :new, status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    result = Tasks::Updater.call(task: @task, task_params: task_params.to_h)

    if result.success?
      redirect_to result.value!, notice: "Задача обновлена."
    else
      @task = result.failure
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    Tasks::Destroyer.call(task: @task)

    redirect_to tasks_url, notice: "Задача удалена."
  end

  private

  def set_task
    @task = Task.find(params[:id])
  end

  def task_params
    params.require(:task).permit(:title, :description, :status, :priority, :deadline)
  end
end
