class CreateTasks < ActiveRecord::Migration[8.1]
  def change
    create_table :tasks do |t|
      t.string :title, null: false
      t.text :description
      t.string :status, null: false, default: "todo"
      t.integer :priority, null: false, default: 0
      t.datetime :deadline

      t.timestamps
    end
  end
end
