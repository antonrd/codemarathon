class AddMarkdownExplanationToQuizQuestions < ActiveRecord::Migration
  def change
    change_column :quiz_questions, :markdown_content, :text, null: false
    add_column :quiz_questions, :markdown_explanation, :text
  end
end
