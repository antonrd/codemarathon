class Course < ActiveRecord::Base
  before_save :render_markdown_description

  validates :title, presence: true
  validates :markdown_description, presence: true
  validates :markdown_long_description, presence: true

  has_many :sections

  def last_section_position
    return 0 if sections.empty?
    sections.ordered.last.position
  end

  protected

  def render_markdown_description
    self.description = RenderMarkdown.new(markdown_description).call
    self.long_description = RenderMarkdown.new(markdown_long_description).call
  end
end
