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
    @task = Task.new(task_params)

    if @task.save
      redirect_to @task, notice: "Задача создана."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    if @task.update(task_params)
      redirect_to @task, notice: "Задача обновлена."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @task.destroy

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