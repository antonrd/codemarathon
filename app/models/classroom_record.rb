class ClassroomRecord < ActiveRecord::Base
  belongs_to :classroom
  belongs_to :user

  validates :classroom, presence: true
  validates :user, presence: true
  validates :role, presence: true

  ROLE_ADMIN = :admin
  ROLE_STUDENT = :student

  scope :admin, -> { where(role: ROLE_ADMIN) }
  scope :student, -> { where(role: ROLE_STUDENT) }
end
