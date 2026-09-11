require "rails_helper"

RSpec.describe Tasks::Updater do
  let(:task) { Task.create!(title: "Старое название") }

  it "updates the task and returns Success with the updated task" do
    result = described_class.call(task: task, task_params: { title: "Новое название" })

    expect(result).to be_success
    expect(result.value!).to eq(task)
    expect(task.reload.title).to eq("Новое название")
  end

  it "returns Failure with the task and does not update it when the title is blank" do
    result = described_class.call(task: task, task_params: { title: "" })

    expect(result).to be_failure
    expect(result.failure).to eq(task)
    expect(task.reload.title).to eq("Старое название")
    expect(result.failure.errors[:title]).to include("can't be blank")
  end

  it "returns Failure when params are not a hash" do
    result = described_class.call(task: task, task_params: "oops")

    expect(result).to be_failure
    expect(task.reload.title).to eq("Старое название")
  end

  it "returns Failure when task is not a Task" do
    result = described_class.call(task: "not a task", task_params: { title: "Задача" })

    expect(result).to be_failure
  end
end
