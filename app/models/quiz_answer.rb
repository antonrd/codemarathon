class QuizAnswer < ActiveRecord::Base
  before_save :render_markdown_content

  belongs_to :quiz_question, inverse_of: :quiz_answers

  validates :quiz_question, presence: true
  validates :markdown_content, presence: true
  validates :correct, inclusion: { in: [true, false] }

  def correct_answer? answer
    correct == answer
  end

  protected

  def render_markdown_content
    self.content = RenderMarkdown.new(markdown_content).call
  end
end
