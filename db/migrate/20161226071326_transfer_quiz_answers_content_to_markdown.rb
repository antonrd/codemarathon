class TransferQuizAnswersContentToMarkdown < ActiveRecord::Migration
  def up
    Quiz.find_each do |quiz|
      quiz.quiz_answers.each do |quiz_answer|
        if quiz_answer.content.present?
          say "Updating content of quiz answers #{ quiz_answer.id }"
          quiz_answer.update_attributes(markdown_content: quiz_answer.content)
        else
          say "Error: empty quiz answer content found!"
        end
      end
    end

    change_column_null(:quiz_answers, :markdown_content, false)
  end

  def down
    change_column_null(:quiz_answers, :markdown_content, true)

    QuizQuestion.update_all(markdown_content: nil)
  end
end
