require "rails_helper"

RSpec.describe Tasks::Destroyer do
  it "destroys the task and returns Success with the task" do
    task = Task.create!(title: "На удаление")

    expect {
      result = described_class.call(task: task)

      expect(result).to be_success
      expect(result.value!).to eq(task)
    }.to change(Task, :count).by(-1)
  end

  it "returns Failure when task is not a Task" do
    result = described_class.call(task: "not a task")

    expect(result).to be_failure
  end
end
