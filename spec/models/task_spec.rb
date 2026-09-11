require "rails_helper"

RSpec.describe Task, type: :model do
  describe "validations" do
    it "requires a title" do
      task = Task.new(title: nil)

      expect(task).not_to be_valid
      expect(task.errors[:title]).to include("can't be blank")
    end

    it "accepts a blank description" do
      task = Task.new(title: "Тест", description: nil)

      expect(task).to be_valid
    end

    it "rejects a deadline in the past" do
      task = Task.new(title: "Тест", deadline: 1.day.ago)

      expect(task).not_to be_valid
      expect(task.errors[:deadline]).to include("не может быть в прошлом")
    end

    it "accepts a deadline in the future" do
      task = Task.new(title: "Тест", deadline: 1.day.from_now)

      expect(task).to be_valid
    end
  end

  describe "status enum" do
    it "defaults to todo" do
      task = Task.new(title: "Тест")

      expect(task.status).to eq("todo")
      expect(task.todo?).to be(true)
    end

    it "supports the three statuses" do
      expect(Task.statuses.keys).to contain_exactly("todo", "in_progress", "done")
    end

    it "rejects an invalid status" do
      expect { Task.new(title: "Тест", status: "invalid_status") }
        .to raise_error(ArgumentError)
    end

    it "updates status" do
      task = Task.create!(title: "Тест")

      task.in_progress!

      expect(task.status).to eq("in_progress")
    end
  end

  describe "priority default" do
    it "defaults to 0" do
      task = Task.new(title: "Тест")

      expect(task.priority).to eq(0)
    end
  end
end