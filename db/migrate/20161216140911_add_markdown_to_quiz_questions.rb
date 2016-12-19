class AddMarkdownToQuizQuestions < ActiveRecord::Migration
  def change
    add_column :quiz_questions, :markdown_content, :text
  end
end
