class AddMarkdownToQuizAnswers < ActiveRecord::Migration
  def change
    add_column :quiz_answers, :markdown_content, :text
  end
end
