class Course < ActiveRecord::Base
  before_save :render_markdown_description

  has_many :sections, dependent: :destroy
  has_many :lessons, through: :sections
  has_many :classrooms, dependent: :destroy
  has_many :tasks, through: :lessons

  validates :title, presence: true
  validates :slug, presence: true
  validates :slug, length: { in: 5..20 }
  validates :slug, format: { with: /[a-z0-9\-]/,
    message: "only allows lower case letters, digits and dashes, "\
              "with length between 5 and 20 symbols" }
  validates :markdown_description, presence: true
  validates :markdown_long_description, presence: true
  validates :visible, inclusion: { in: [true, false] }
  validates :is_main, inclusion: { in: [true, false] }

  scope :visible, -> { where(visible: true) }
  scope :main, -> { where(is_main: true, visible: true) }

  def to_param
    slug
  end

  def self.visible_for user
    user.present? && user.is_teacher? ? self.all : self.visible
  end

  def last_section_position
    return 0 if sections.empty?
    sections.maximum(:position)
  end

  def first_visible_lesson user
    sections_visible_for(user).ordered.each do |section|
      visible_lesson = section.first_visible_lesson(user)
      return visible_lesson if visible_lesson.present?
    end

    nil
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
