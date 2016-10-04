class AddLessonsQuizzesTable < ActiveRecord::Migration
  def change
    create_table :lessons_quizzes do |t|
      t.integer :lesson_id
      t.integer :quiz_id
    end
  end
end
