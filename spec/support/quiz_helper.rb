module QuizHelper
  def generate_quiz_answers quiz_questions
    answers = {}

    quiz_questions.each do |quiz_question|
      if quiz_question.question_type == QuizQuestion::TYPE_MULTIPLE_CHOICE
        answers[quiz_question.id.to_s] = {}
        answers[quiz_question.id.to_s]["multiple_answers"] = {}

        quiz_question.quiz_answers.each do |quiz_answer|
          answers[quiz_question.id.to_s]["multiple_answers"][quiz_answer.id.to_s] = 1
        end

      else
        is_correct = quiz_question.correct_freetext_answer?("abc")

        answers[quiz_question.id.to_s] = {}
        answers[quiz_question.id.to_s]["freetext_answer"] = "abc"
      end
    end

    { 'quiz_attempt' => answers }
  end
end
