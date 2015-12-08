class CreateTableLessonTasks < ActiveRecord::Migration
  def change
    create_table :lessons_tasks do |t|
      t.integer :lesson_id
      t.integer :task_id
    end
  end
end
