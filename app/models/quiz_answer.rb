class QuizAnswer < ActiveRecord::Base
  belongs_to :quiz_question, inverse_of: :quiz_answers

  validates :quiz_question, presence: true
  validates :content, presence: true
  validates :correct, inclusion: { in: [true, false] }

  def correct_answer? answer
    correct == answer
  end
end
