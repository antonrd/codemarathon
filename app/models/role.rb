class Role < ApplicationRecord
  belongs_to :user

  validates :user, presence: true
  validates :role_type, presence: true
  validates :role_type, inclusion: { in: User::ROLES.map(&:to_s) }
end
