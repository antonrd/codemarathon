class ClassroomRecord < ApplicationRecord
  belongs_to :classroom
  belongs_to :user

  validates :classroom, presence: true
  validates :user, presence: true
  validates :role, presence: true
  validates :user, uniqueness: { scope: :classroom }

  ROLE_ADMIN = :admin
  ROLE_STUDENT = :student

  scope :admin, -> { where(role: ROLE_ADMIN) }
  scope :student, -> { where(role: ROLE_STUDENT) }
  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
end
