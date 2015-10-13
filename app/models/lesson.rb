class Lesson < ActiveRecord::Base
  validates :title, presence: true
  validates :position, presence: true
  validates :section, presence: true

  belongs_to :section

  scope :ordered, -> { order('position ASC') }

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
end
