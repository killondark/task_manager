require "rails_helper"

RSpec.describe "Tasks", type: :request do
  describe "GET /tasks" do
    it "returns a successful response" do
      Task.create!(title: "Задача 1")

      get tasks_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Задача 1")
    end
  end

  describe "GET /tasks/:id" do
    it "returns a successful response" do
      task = Task.create!(title: "Задача", description: "Описание")

      get task_path(task)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Задача")
      expect(response.body).to include("Описание")
    end
  end

  describe "GET /tasks/new" do
    it "returns a successful response" do
      get new_task_path

      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /tasks" do
    context "with valid params" do
      it "creates a new task and redirects" do
        expect {
          post tasks_path, params: { task: { title: "Новая задача", deadline: 1.day.from_now } }
        }.to change(Task, :count).by(1)

        task = Task.last
        expect(task.status).to eq("todo")
        expect(response).to redirect_to(task_path(task))
      end
    end

    context "with invalid params" do
      it "does not create a task" do
        expect {
          post tasks_path, params: { task: { title: "" } }
        }.not_to change(Task, :count)

        expect(response).to have_http_status(:unprocessable_content)
      end

      it "rejects a past deadline" do
        expect {
          post tasks_path, params: { task: { title: "Задача", deadline: 1.day.ago } }
        }.not_to change(Task, :count)

        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "GET /tasks/:id/edit" do
    it "returns a successful response" do
      task = Task.create!(title: "Задача")

      get edit_task_path(task)

      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /tasks/:id" do
    context "with valid params" do
      it "updates the task and redirects" do
        task = Task.create!(title: "Старое название")

        patch task_path(task), params: { task: { title: "Новое название" } }

        task.reload
        expect(task.title).to eq("Новое название")
        expect(response).to redirect_to(task_path(task))
      end
    end

    context "with invalid params" do
      it "does not update the task" do
        task = Task.create!(title: "Название")

        patch task_path(task), params: { task: { title: "" } }

        expect(task.reload.title).to eq("Название")
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "DELETE /tasks/:id" do
    it "deletes the task and redirects" do
      task = Task.create!(title: "На удаление")

      expect {
        delete task_path(task)
      }.to change(Task, :count).by(-1)

      expect(response).to redirect_to(tasks_path)
    end
  end
end