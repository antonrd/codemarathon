class CreateQuizQuestions < ActiveRecord::Migration
  def change
    create_table :quiz_questions do |t|
      t.integer :quiz_id, null: false
      t.text :content, null: false
      t.string :question_type, null: false
      t.string :freetext_regex

      t.timestamps null: false
    end
  end
end
