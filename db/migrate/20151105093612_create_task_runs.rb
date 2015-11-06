class CreateTaskRuns < ActiveRecord::Migration
  def change
    create_table :task_runs do |t|
      t.integer :task_id, null: false
      t.integer :user_id, null: false
      t.text :source_code, null: false
      t.string :lang, null: false
      t.string :status, null: false
      t.string :external_key
      t.string :message
      t.text :grader_log
      t.integer :memory_limit_kb, null: false
      t.integer :time_limit_ms, null: false

      t.timestamps null: false
    end
  end
end
