class AddMarkdownExplanationToQuizQuestions < ActiveRecord::Migration
  def change
    add_column :quiz_questions, :markdown_explanation, :text
  end
end
