class ScoreQuizAttempt
  def initialize quiz, user, params
    @quiz = quiz
    @user = user
    @params = params
  end

  def call
    score_quiz_attempt
  end

  private

  attr_reader :quiz, :params, :user

  def score_quiz_attempt
    report_error("No root.") unless params.has_key?("quiz_attempt")

    quiz_score = 0.0
    quiz_summary = {}

    quiz.quiz_questions.each do |quiz_question|
      question_score = score_quiz_question(quiz_question, quiz_summary)

      quiz_summary[quiz_question.id][:score] = question_score
      quiz_score += question_score
    end

    quiz.quiz_attempts.create!(user: user,
      score: quiz_score,
      answers_json: quiz_summary.to_json,
      message: 'Quiz scored successfully')

    if quiz.is_covered_by?(user)
      quiz.lessons.each do |lesson|
        lesson.cover_lesson_records_if_lesson_covered(user)
      end
    end
  end

  def score_quiz_question quiz_question, quiz_summary
    unless params["quiz_attempt"].has_key?(quiz_question.id.to_s)
      report_error("Question #{ quiz_question.id } missing.")
    end

    question_answers = params["quiz_attempt"][quiz_question.id.to_s]

    question_score = 0.0

    if quiz_question.multiple_choice?
      score_multiple_answers_question(quiz_question, quiz_summary)
    else
      score_freetext_question(quiz_question, quiz_summary)
    end
  end

  def score_multiple_answers_question quiz_question, quiz_summary
    user_question_answers = params["quiz_attempt"][quiz_question.id.to_s]

    unless user_question_answers.has_key?("multiple_answers")
      report_error("Question #{ quiz_question.id } has no proper answers.")
    end

    multiple_answers = user_question_answers["multiple_answers"]
    correct_answers = 0.0
    quiz_summary[quiz_question.id] = {}

    quiz_question.quiz_answers.each do |quiz_answer|
      if score_one_question_answer(user_question_answers, quiz_question, quiz_answer, quiz_summary)
        correct_answers += 1
      end
    end

    correct_answers.to_f / quiz_question.quiz_answers.count
  end

  def score_one_question_answer user_question_answers, quiz_question, quiz_answer, quiz_summary
    user_multiple_answers = user_question_answers["multiple_answers"]

    unless user_multiple_answers.has_key?(quiz_answer.id.to_s)
      report_error("Missing multiple answer for question #{ quiz_question.id } - #{ quiz_answer.id }")
    end

    is_correct = false

    user_answer = user_multiple_answers[quiz_answer.id.to_s].to_i
    if (quiz_answer.correct && user_answer == 1) ||
      (!quiz_answer.correct && user_answer == 0)

      is_correct = true
    end

    user_checked = user_multiple_answers[quiz_answer.id.to_s] == "1"
    quiz_summary[quiz_question.id][quiz_answer.id] = {
      user_answer: user_checked,
      correct_answer: quiz_answer.correct,
      is_correct: user_checked == quiz_answer.correct
    }

    is_correct
  end

  def score_freetext_question quiz_question, quiz_summary
    question_answers = params["quiz_attempt"][quiz_question.id.to_s]
    question_score = 0.0

    unless question_answers.has_key?("freetext_answer")
      report_error("Missing freetext answer for question #{ quiz_question.id }")
    end

    user_answer = question_answers["freetext_answer"]

    if quiz_question.correct_freetext_answer?(question_answers["freetext_answer"])
      question_score = 1.0
    end

    quiz_summary[quiz_question.id] = {
      user_answer: user_answer,
      correct_answer: quiz_question.freetext_regex,
      is_correct: quiz_question.correct_freetext_answer?(user_answer)
    }

    question_score
  end

  def report_error message
    raise "Invalid quiz submission. #{ message }"
  end
end
