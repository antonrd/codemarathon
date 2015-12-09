class CreateTaskRecords < ActiveRecord::Migration
  def change
    create_table :task_records do |t|
      t.integer :user_id, null: false
      t.integer :task_id, null: false
      t.float :best_score, default: 0.0, null: false
      t.integer :best_run_id
      t.boolean :covered, default: false, null: false

      t.timestamps null: false
    end
  end
end
