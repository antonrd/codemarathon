class Role < ActiveRecord::Base
  belongs_to :user

  validates :user_id, presence: true
  validates :role_type, presence: true
end
