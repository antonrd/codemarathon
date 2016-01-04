class Course < ActiveRecord::Base
  before_save :render_markdown_description

  has_many :sections
  has_many :classrooms

  validates :title, presence: true
  validates :markdown_description, presence: true
  validates :markdown_long_description, presence: true
  validates :visible, inclusion: { in: [true, false] }

  scope :visible, -> { where(visible: true) }

  def self.visible_for user
    user.present? && user.is_teacher? ? self.all : self.visible
  end

  def last_section_position
    return 0 if sections.empty?
    sections.maximum(:position)
  end

  def first_visible_lesson user
    return if sections.empty? || sections_visible_for(user).ordered.first.lessons.empty?
    if user.present? && user.is_teacher?
      sections.ordered.first.lessons.ordered.first
    else
      sections_visible_for(user).ordered.first.first_visible_lesson(user)
    end
  end

  def sections_visible_for user
    user.present? && user.is_teacher? ? sections : sections.visible
  end

  protected

  def render_markdown_description
    self.description = RenderMarkdown.new(markdown_description).call
    self.long_description = RenderMarkdown.new(markdown_long_description).call
  end
end
