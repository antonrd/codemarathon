# TODO: Extract all the common logic with lessons and do the same for specs.
class Section < ActiveRecord::Base
  belongs_to :course
  has_many :lessons

  validates :title, presence: true
  validates :position, presence: true
  validates :course, presence: true
  validates :visible, inclusion: { in: [true, false] }

  scope :ordered, -> { order('position ASC') }
  scope :visible, -> { where(visible: true) }

  def is_first?
    course.sections.ordered.first.id == id
  end

  def is_last?
    course.sections.ordered.last.id == id
  end

  def move_up
    return if is_first?

    Section.transaction do
      new_positon = previous_section.position

      previous_section.update_attributes(position: position)
      update_attributes(position: new_positon)
    end
  end

  def move_down
    return if is_last?

    Section.transaction do
      new_positon = next_section.position

      next_section.update_attributes(position: position)
      update_attributes(position: new_positon)
    end
  end

  def last_lesson_position
    return 0 if lessons.empty?
    lessons.ordered.last.position
  end

  def lessons_visible_for user
    user.present? && user.is_teacher? ? lessons : lessons.visible
  end

  protected

  def previous_section
    return if is_first?

    ordered_sections = course.sections.ordered
    current_index = ordered_sections.find_index(self)

    ordered_sections[current_index - 1]
  end

  def next_section
    return if is_last?

    ordered_sections = course.sections.ordered
    current_index = ordered_sections.find_index(self)

    ordered_sections[current_index + 1]
  end
end
