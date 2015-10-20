class ClassroomRecord < ActiveRecord::Base
  belongs_to :classroom
  belongs_to :user

  ROLE_ADMIN = :admin
  ROLE_STUDENT = :student
end
