class Classroom < ActiveRecord::Base
  belongs_to :course
  has_many :classroom_records, dependent: :destroy

  validates :name, presence: true
  validates :course, presence: true
  validates :slug, presence: true
  validates :slug, uniqueness: true
  validates :slug, length: { in: 5..20 }
  validates :slug, format: { with: /[a-z0-9\-]/,
    message: "only allows lower case letters, digits and dashes, "\
              "with length between 5 and 20 symbols" }

  def to_param
    slug
  end

  def add_admin user
    unless has_access?(user)
      classroom_records.create!(user: user, role: ClassroomRecord::ROLE_ADMIN)
    end
  end

  def is_admin? user
    classroom_records.exists?(user: user, role: ClassroomRecord::ROLE_ADMIN)
  end

  def add_student user
    unless has_access?(user)
      classroom_records.create!(user: user, role: ClassroomRecord::ROLE_STUDENT)
    end
  end

  def is_student? user
    classroom_records.exists?(user: user, role: ClassroomRecord::ROLE_STUDENT)
  end

  def has_access? user
    is_admin?(user) || is_student?(user)
  end

  def remove_user user
    classroom_records.where(user: user).delete_all
  end

  def find_lesson lesson_id
    lesson = Lesson.find(lesson_id)
    return if course.id != lesson.section.course_id

    lesson
  end

  def find_task task_id, lesson_id
    lesson = find_lesson lesson_id
    return unless lesson

    lesson.tasks.find(task_id)
  end
end
