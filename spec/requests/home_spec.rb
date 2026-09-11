require "rails_helper"

RSpec.describe "Home", type: :request do
  it "returns 200 for the root path" do
    get "/"

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Task Manager")
  end

  it "renders status counters and empty-state for an empty database" do
    get "/"

    expect(response.body).to include("Всего")
    expect(response.body).to include("Прогресс выполнения")
    expect(response.body).to include("0%")
    expect(response.body).to include("Задач пока нет.")
  end

  it "renders counters, progress and recent task titles" do
    Task.create!(title: "Готовая задача", status: "done")
    Task.create!(title: "Активная задача", status: "in_progress")
    Task.create!(title: "Ожидающая задача", status: "todo")

    get "/"

    expect(response.body).to include("Всего")
    expect(response.body).to include("Done")
    expect(response.body).to include("In progress")
    expect(response.body).to include("Todo")
    expect(response.body).to include("33%")
    expect(response.body).to include("Готовая задача")
    expect(response.body).to include("Активная задача")
    expect(response.body).to include("Ожидающая задача")
  end

  it "renders a link to the full task list" do
    get "/"

    expect(response.body).to include(tasks_path)
  end
end
