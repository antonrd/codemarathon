class Course < ActiveRecord::Base
  before_save :render_markdown_description

  validates :title, presence: true
  validates :markdown_description, presence: true
  validates :markdown_long_description, presence: true

  has_many :sections
  has_many :classrooms

  scope :visible, -> { where(visible: true) }

  def self.visible_for user
    user.present? && user.is_teacher? ? self.all : self.visible
  end

  def last_section_position
    return 0 if sections.empty?
    sections.ordered.last.position
  end

  def first_lesson
    return if sections.empty? || sections.first.lessons.empty?
    sections.first.lessons.first
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
