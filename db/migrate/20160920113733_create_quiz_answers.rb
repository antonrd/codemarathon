class CreateQuizAnswers < ActiveRecord::Migration
  def change
    create_table :quiz_answers do |t|
      t.integer :quiz_question_id, null: false
      t.text :content, null: false
      t.boolean :correct, null: false

      t.timestamps null: false
    end
  end
end
