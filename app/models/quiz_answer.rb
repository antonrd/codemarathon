class QuizAnswer < ActiveRecord::Base
  belongs_to :quiz_question

  # validates :quiz_question_id, presence: true
  validates :content, presence: true
  validates :correct, inclusion: { in: [true, false] }

  def correct_answer? answer
    correct == answer
  end
end
