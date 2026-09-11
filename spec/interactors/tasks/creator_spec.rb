require "rails_helper"

RSpec.describe Tasks::Creator do
  it "creates a task and returns Success with the saved task" do
    expect {
      result = described_class.call(task_params: { title: "Купить продукты" })

      expect(result).to be_success
      expect(result.value!).to be_persisted
      expect(result.value!.title).to eq("Купить продукты")
    }.to change(Task, :count).by(1)
  end

  it "returns Failure with the unsaved task when the title is blank" do
    result = described_class.call(task_params: { title: "" })

    expect(result).to be_failure
    expect(result.failure).to be_a(Task)
    expect(result.failure).not_to be_persisted
    expect(result.failure.errors[:title]).to include("can't be blank")
  end

  it "returns Failure for a deadline in the past and does not create a task" do
    expect {
      result = described_class.call(task_params: { title: "Задача", deadline: 1.day.ago })

      expect(result).to be_failure
    }.not_to change(Task, :count)
  end

  it "returns Failure for an empty params hash and does not create a task" do
    expect {
      result = described_class.call(task_params: {})

      expect(result).to be_failure
    }.not_to change(Task, :count)
  end

  it "returns Failure when params are not a hash" do
    expect {
      result = described_class.call(task_params: "oops")

      expect(result).to be_failure
    }.not_to change(Task, :count)
  end
end
