class Classroom < ActiveRecord::Base
  validates :name, presence: true
  validates :course_id, presence: true

  belongs_to :course
  has_many :classroom_records

  def add_admin user
    classroom_records.create(user: user, role: ClassroomRecord::ROLE_ADMIN)
  end

  def is_admin? user
    classroom_records.exists?(user: user, role: ClassroomRecord::ROLE_ADMIN)
  end

  def add_student user
    classroom_records.create(user: user, role: ClassroomRecord::ROLE_STUDENT)
  end

  def is_student? user
    classroom_records.exists?(user: user, role: ClassroomRecord::ROLE_STUDENT)
  end
end
