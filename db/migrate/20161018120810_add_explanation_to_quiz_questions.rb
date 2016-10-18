class AddExplanationToQuizQuestions < ActiveRecord::Migration
  def change
    add_column :quiz_questions, :explanation, :text
  end
end
