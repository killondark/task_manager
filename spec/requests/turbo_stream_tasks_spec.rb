require "rails_helper"

RSpec.describe "Tasks (turbo_stream)", type: :request do
  def turbo_stream_headers(extra = {})
    { "Accept" => "text/vnd.turbo-stream.html" }.merge(extra)
  end

  describe "POST /tasks" do
    context "as a modal frame submission" do
      it "creates a task and responds with a turbo_stream append" do
        expect {
          post tasks_path,
            params: { task: { title: "Новая задача", priority: 3 } },
            headers: turbo_stream_headers("Turbo-Frame" => "task_modal")
        }.to change(Task, :count).by(1)

        task = Task.last
        expect(response.media_type).to eq("text/vnd.turbo-stream.html")
        expect(response.body).to include('turbo-stream action="append"')
        expect(response.body).to include('target="tasks_list"')
        expect(response.body).to include("task_#{task.id}")
        expect(response.body).to include("Новая задача")
      end
    end

    context "as a non-frame turbo_stream request" do
      it "falls back to an HTML redirect" do
        expect {
          post tasks_path,
            params: { task: { title: "Новая задача" } },
            headers: turbo_stream_headers
        }.to change(Task, :count).by(1)

        expect(response).to redirect_to(task_path(Task.last))
      end
    end

    context "with invalid params" do
      it "responds with 422 and re-renders the modal form" do
        expect {
          post tasks_path,
            params: { task: { title: "" } },
            headers: turbo_stream_headers("Turbo-Frame" => "task_modal")
        }.not_to change(Task, :count)

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include('turbo-stream action="replace"')
        expect(response.body).to include('target="task_modal"')
        expect(response.body).to include("Сохранить задачу")
      end
    end
  end

  describe "PATCH /tasks/:id" do
    context "as a modal frame submission" do
      it "updates the task and responds with a turbo_stream replace" do
        task = Task.create!(title: "Старое название")

        patch task_path(task),
          params: { task: { title: "Новое название" } },
          headers: turbo_stream_headers("Turbo-Frame" => "task_modal")

        expect(task.reload.title).to eq("Новое название")
        expect(response.media_type).to eq("text/vnd.turbo-stream.html")
        expect(response.body).to include('turbo-stream action="replace"')
        expect(response.body).to include("task_#{task.id}")
        expect(response.body).to include("Новое название")
      end
    end

    context "with invalid params" do
      it "responds with 422 and re-renders the modal form" do
        task = Task.create!(title: "Название")

        patch task_path(task),
          params: { task: { title: "" } },
          headers: turbo_stream_headers("Turbo-Frame" => "task_modal")

        expect(task.reload.title).to eq("Название")
        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include('target="task_modal"')
        expect(response.body).to include("Сохранить задачу")
      end
    end
  end

  describe "PATCH /tasks/:id/status" do
    it "updates the status and responds with a turbo_stream replace" do
      task = Task.create!(title: "Задача", status: "todo")

      patch status_task_path(task), params: { status: "done" }, headers: turbo_stream_headers

      expect(task.reload.status).to eq("done")
      expect(response.media_type).to eq("text/vnd.turbo-stream.html")
      expect(response.body).to include('turbo-stream action="replace"')
      expect(response.body).to include("task_#{task.id}")
    end

    it "updates the status and redirects for plain HTML requests" do
      task = Task.create!(title: "Задача", status: "todo")

      patch status_task_path(task), params: { status: "in_progress" }

      expect(task.reload.status).to eq("in_progress")
      expect(response).to redirect_to(tasks_path)
    end
  end

  describe "DELETE /tasks/:id" do
    it "deletes the task and responds with a turbo_stream remove" do
      task = Task.create!(title: "На удаление")

      expect {
        delete task_path(task), headers: turbo_stream_headers
      }.to change(Task, :count).by(-1)

      expect(response.media_type).to eq("text/vnd.turbo-stream.html")
      expect(response.body).to include('turbo-stream action="remove"')
      expect(response.body).to include("task_#{task.id}")
    end
  end
end
