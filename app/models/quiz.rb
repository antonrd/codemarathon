class Quiz < ActiveRecord::Base
  has_many :quiz_questions, inverse_of: :quiz
  has_many :quiz_attempts
  belongs_to :creator, class_name: "User", foreign_key: "creator_id"
  has_and_belongs_to_many :lessons

  accepts_nested_attributes_for :quiz_questions, allow_destroy: true

  validates :title, presence: true
  validates :creator, presence: true

  def self.unused_quizzes_for lesson
    where.not(id: lesson.quizzes.map(&:id))
  end

  def attempts_depleted? user
    maximum_attempts && user_attempts(user).count >= maximum_attempts
  end

  def last_attempt_too_soon? user
    wait_time_seconds && user_attempts(user).present? &&
      passed_time_since_last_attempt(user) < wait_time_seconds
  end

  def user_attempts user
    quiz_attempts.where(user: user)
  end

  def maximum_score user
    if user_attempts(user).present?
      user_attempts(user).maximum(:score).round(2)
    else
      0.0
    end
  end

  def is_covered_by? user
    maximum_score(user) == quiz_questions.count
  end

  def max_points
    quiz_questions.count
  end

  private

  def passed_time_since_last_attempt user
    Time.now - user_attempts(user).latest_first.first.created_at
  end
end
