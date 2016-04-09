require 'rouge/plugins/redcarpet'

class RenderMarkdown
  class Renderer < Redcarpet::Render::HTML
    include Rouge::Plugins::Redcarpet
  end

  def initialize(markdown)
    @markdown = markdown
  end

  def call
    render
  end

  protected

  attr_reader :markdown

  def markdown_renderer
    @markdown_renderer ||= Redcarpet::Markdown.new(Renderer,
      autolink: true, tables: true, fenced_code_blocks: true, hard_wrap: true)
  end

  def render
    markdown_renderer.render(markdown)
  end
end
