class UserInvitation < ApplicationRecord
  validates :email, presence: true, uniqueness: true
end
