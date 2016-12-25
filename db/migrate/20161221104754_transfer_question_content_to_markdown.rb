class TransferQuestionContentToMarkdown < ActiveRecord::Migration
  def change
    Quiz.find_each do |quiz|
      quiz.quiz_questions.each do |quiz_question|
        if quiz_question.content.present?
          quiz_markdown = quiz_question.content
          quiz_question.update_attributes(markdown_content: quiz_markdown)
        end
      end
    end
  end
end
