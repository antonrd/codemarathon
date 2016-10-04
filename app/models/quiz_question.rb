class QuizQuestion < ActiveRecord::Base
  belongs_to :quiz
  has_many :quiz_answers

  accepts_nested_attributes_for :quiz_answers, allow_destroy: true

  validates :quiz, presence: true
  validates :content, presence: true
  validates :question_type, presence: true

  TYPE_MULTIPLE_CHOICE = 'multiple'
  TYPE_FREETEXT = 'freetext'

  scope :ordered, -> { order("created_at ASC") }

  def multiple_choice?
    question_type == TYPE_MULTIPLE_CHOICE
  end

  def freetext?
    question_type == TYPE_FREETEXT
  end

  def correct_freetext_answer? answer
    freetext? && Regexp.new(freetext_regex).match(answer)
  end
end
