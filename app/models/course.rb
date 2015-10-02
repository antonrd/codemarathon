class Course < ActiveRecord::Base
  before_save :render_markdown_description

  validates :title, presence: true
  validates :markdown_description, presence: true
  validates :description, presence: true
  validates :markdown_long_description, presence: true
  validates :long_description, presence: true

  protected

  def render_markdown_description
    self.description = RenderMarkdown.new(markdown_description).call
    self.long_description = RenderMarkdown.new(markdown_long_description).call
  end
end
