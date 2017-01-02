class TransferQuestionContentToMarkdown < ActiveRecord::Migration
  def up
    QuizQuestion.find_each do |quiz_question|
      if quiz_question.content.present?
        say "Updating content of quiz questions #{ quiz_question.id }"
        quiz_question.update_attributes(markdown_content: quiz_question.content)
      else
        say "Error: empty quiz question content found!"
      end

      if quiz_question.explanation.present?
        say "Updating explanation of quiz questions #{ quiz_question.id }"
        quiz_question.update_attributes(markdown_explanation: quiz_question.explanation)
      end
    end


    change_column_null(:quiz_questions, :markdown_content, false)
  end

  def down
    change_column_null(:quiz_questions, :markdown_content, true)

    QuizQuestion.update_all(markdown_content: nil, markdown_explanation: nil)
  end
end
