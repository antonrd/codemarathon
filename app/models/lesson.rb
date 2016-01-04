# TODO: Extract all the common logic with sections and do the same for specs.
class Lesson < ActiveRecord::Base
  before_save :render_markdown_content

  belongs_to :section
  has_many :lesson_records
  has_and_belongs_to_many :tasks

  validates :title, presence: true
  validates :position, presence: true
  validates :section, presence: true
  validates :visible, inclusion: { in: [true, false] }

  scope :ordered, -> { order('position ASC') }
  scope :visible, -> { where(visible: true) }

  def is_first?
    section.lessons.ordered.first.id == id
  end

  def is_last?
    section.lessons.ordered.last.id == id
  end

  def move_up
    return if is_first?

    Lesson.transaction do
      new_positon = previous_lesson.position

      previous_lesson.update_attributes(position: position)
      update_attributes(position: new_positon)
    end
  end

  def move_down
    return if is_last?

    Lesson.transaction do
      new_positon = next_lesson.position

      next_lesson.update_attributes(position: position)
      update_attributes(position: new_positon)
    end
  end

  def lesson_record_for(classroom, user)
    lesson_records.find_or_create_by(classroom: classroom, user: user)
  end

  def all_tasks_covered_by?(user)
    tasks.map { |task| task.is_covered_by?(user) }.all?
  end

  def count_covered_tasks_by(user)
    tasks.to_a.count { |task| task.is_covered_by?(user) }
  end

  def covered?(classroom, user)
    lesson_record_for(classroom, user).covered
  end

  def cover_lesson_records_if_lesson_covered(user)
    if all_tasks_covered_by?(user)
      lesson_records.where(user: user).each do |lesson_record|
        lesson_record.update_attributes(covered: true) if lesson_record.views > 0
      end
    end
  end

  protected

  def previous_lesson
    return if is_first?

    ordered_lessons = section.lessons.ordered
    current_index = ordered_lessons.find_index(self)

    ordered_lessons[current_index - 1]
  end

  def next_lesson
    return if is_last?

    ordered_lessons = section.lessons.ordered
    current_index = ordered_lessons.find_index(self)

    ordered_lessons[current_index + 1]
  end

  def render_markdown_content
    self.content = RenderMarkdown.new(markdown_content).call if markdown_content.present?
  end

end
