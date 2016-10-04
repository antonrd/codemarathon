describe ScoreQuizAttempt do
  let(:score_quiz_attempt) { ScoreQuizAttempt.new }
  # let(:answers_json) { File.open('spec/fixtures/quiz_attempt_answers.json').read }
  # let(:params) { JSON.parse(answers_json) }
  let(:user) { FactoryGirl.create(:user) }

  let(:classroom) { FactoryGirl.create(:classroom) }
  let(:lesson) { FactoryGirl.create(:lesson) }
  let(:lesson_record) { lesson.lesson_record_for(classroom, user) }
  let(:quiz) { FactoryGirl.create(:quiz) }
  let(:quiz_question1) { FactoryGirl.create(:quiz_question,
    question_type: QuizQuestion::TYPE_MULTIPLE_CHOICE, quiz: quiz) }
  let(:quiz_question2) { FactoryGirl.create(:quiz_question,
    question_type: QuizQuestion::TYPE_FREETEXT,
    freetext_regex: "\\A[a-z]+\\z", quiz: quiz) }

  let!(:quiz_answer1) { FactoryGirl.create(:quiz_answer,
    quiz_question: quiz_question1, correct: false) }
  let!(:quiz_answer2) { FactoryGirl.create(:quiz_answer,
    quiz_question: quiz_question1, correct: true) }

  let(:params) { generate_quiz_answers([quiz_question1, quiz_question2]) }

  describe "#call" do
    before do
      lesson.quizzes << quiz
      ScoreQuizAttempt.new(quiz, user, params).call
    end

    it "computes the score for one quiz attempt" do
      expect(QuizAttempt.last.score).to eq(1.5)
    end

    it "stores the quiz attempt answers" do
      answers = JSON.parse(QuizAttempt.last.answers_json)
      expect(answers.has_key?(quiz_question1.id.to_s)).to be_truthy
    end
  end
end
