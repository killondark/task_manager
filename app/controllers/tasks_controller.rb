class TasksController < ApplicationController
  before_action :set_task, only: %i[show edit update destroy update_status]

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
      @task = result.value!

      respond_to do |format|
        format.turbo_stream do
          if turbo_frame_request?
            flash.now[:notice] = "Задача создана."
          else
            redirect_to @task, notice: "Задача создана."
          end
        end
        format.html { redirect_to @task, notice: "Задача создана." }
      end
    else
      @task = result.failure
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace("task_modal", template: "tasks/_modal_form", locals: { task: @task }),
            status: :unprocessable_content
        end
        format.html { render :new, status: :unprocessable_content }
      end
    end
  end

  def edit
  end

  def update
    result = Tasks::Updater.call(task: @task, task_params: task_params.to_h)

    if result.success?
      @task = result.value!

      respond_to do |format|
        format.turbo_stream do
          if turbo_frame_request?
            flash.now[:notice] = "Задача обновлена."
          else
            redirect_to @task, notice: "Задача обновлена."
          end
        end
        format.html { redirect_to @task, notice: "Задача обновлена." }
      end
    else
      @task = result.failure
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace("task_modal", template: "tasks/_modal_form", locals: { task: @task }),
            status: :unprocessable_content
        end
        format.html { render :edit, status: :unprocessable_content }
      end
    end
  end

  def update_status
    result = Tasks::Updater.call(task: @task, task_params: { status: params[:status] })

    if result.success?
      @task = result.value!
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to tasks_url, notice: "Статус обновлён." }
      end
    else
      redirect_to tasks_url, alert: "Не удалось изменить статус."
    end
  end

  def destroy
    @task = Tasks::Destroyer.call(task: @task).value!

    respond_to do |format|
      format.turbo_stream do
        flash.now[:notice] = "Задача удалена."
      end
      format.html { redirect_to tasks_url, notice: "Задача удалена." }
    end
  end

  private

  def set_task
    @task = Task.find(params[:id])
  end

  def task_params
    params.require(:task).permit(:title, :description, :status, :priority, :deadline)
  end

  def turbo_frame_request?
    request.headers["Turbo-Frame"].present?
  end
end
