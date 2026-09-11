require "rails_helper"

RSpec.describe "Tasks filters", type: :request do
  before do
    Task.create!(title: "Задача todo")
    Task.create!(title: "Задача in_progress", status: "in_progress")
    Task.create!(title: "Задача done", status: "done")
    Task.create!(title: "Задача приоритет 5", priority: 5)
  end

  describe "GET /tasks?status=in_progress" do
    it "returns only tasks with the filtered status" do
      get tasks_path, params: { status: "in_progress" }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Задача in_progress")
      expect(response.body).not_to include("Задача todo")
    end
  end

  describe "GET /tasks?priority=5" do
    it "returns only tasks with the filtered priority" do
      get tasks_path, params: { priority: 5 }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Задача приоритет 5")
      expect(response.body).not_to include("Задача todo")
    end
  end
end
