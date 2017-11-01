class QuizAttempt < ApplicationRecord
  belongs_to :quiz
  belongs_to :user

  validates :quiz, presence: true
  validates :user, presence: true
  validates :score, presence: true
  validates :answers_json, presence: true

  scope :latest_first, -> { order('created_at DESC') }

  def deserialize_answers
    JSON.parse(answers_json).with_indifferent_access
  end
end
