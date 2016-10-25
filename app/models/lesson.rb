# TODO: Extract all the common logic with sections and do the same for specs.
class Lesson < ActiveRecord::Base
  before_save :render_markdown_content

  belongs_to :section
  has_many :lesson_records, dependent: :destroy
  has_and_belongs_to_many :tasks
  has_and_belongs_to_many :quizzes

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

  def previous_visible_lesson_in_course admin_user: false
    curr_lesson = previous_lesson
    while curr_lesson.present? && !admin_user && !curr_lesson.visible
      curr_lesson = curr_lesson.previous_lesson
    end

    curr_lesson
  end

  def next_visible_lesson_in_course admin_user: false
    curr_lesson = next_lesson
    while curr_lesson.present? && !admin_user && !curr_lesson.visible
      curr_lesson = curr_lesson.next_lesson
    end

    curr_lesson
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
    lesson_records.find_or_create_by(classroom: classroom, user: user) if user.present?
  end

  def all_tasks_covered_by?(user)
    if user.present?
      tasks.map { |task| task.is_covered_by?(user) }.all?
    else
      tasks.empty?
    end
  end

  def all_quizzes_covered_by?(user)
    if user.present?
      quizzes.map { |quiz| quiz.is_covered_by?(user) }.all?
    else
      quizzes.empty?
    end
  end

  def count_covered_tasks_by(user)
    if user.present?
      tasks.to_a.count { |task| task.is_covered_by?(user) }
    else
      0
    end
  end

  def marked_covered?(classroom, user)
    user.present? && lesson_record_for(classroom, user).covered
  end

  def cover_lesson_records_if_lesson_covered(user)
    if is_covered?(user)
      lesson_records.where(user: user).each do |lesson_record|
        lesson_record.update_attributes(covered: true) if lesson_record.views > 0
      end
    end
  end

  def is_covered?(user)
    all_tasks_covered_by?(user) && all_quizzes_covered_by?(user)
  end

  protected

  def previous_lesson
    unless is_first?
      section.lessons.find_by(position: position - 1)
    else
      prev_section = section.previous_section
      while prev_section.present? && prev_section.lessons.empty?
        prev_section = prev_section.previous_section
      end
      return if prev_section.nil?
      prev_section.lessons.ordered.last
    end
  end

  def next_lesson
    unless is_last?
      section.lessons.find_by(position: position + 1)
    else
      next_section = section.next_section
      while next_section.present? && next_section.lessons.empty?
        next_section = next_section.next_section
      end
      return if next_section.nil?
      next_section.lessons.ordered.first
    end
  end

  def render_markdown_content
    if markdown_content.present?
      self.content = RenderMarkdown.new(markdown_content).call
    end

    if markdown_sidebar_content.present?
      self.sidebar_content = RenderMarkdown.new(markdown_sidebar_content).call
    end
  end

end
