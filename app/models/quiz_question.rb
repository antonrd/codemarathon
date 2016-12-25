class QuizQuestion < ActiveRecord::Base
  before_save :render_markdown_content
  before_save :render_markdown_explanation

  belongs_to :quiz, inverse_of: :quiz_questions
  has_many :quiz_answers, inverse_of: :quiz_question

  accepts_nested_attributes_for :quiz_answers, allow_destroy: true

  validates :quiz, presence: true
  validates :question_type, presence: true
  validates :markdown_content, presence: true

  TYPE_MULTIPLE_CHOICE = 'multiple'
  TYPE_FREETEXT = 'freetext'

  scope :ordered, -> { order("created_at ASC") }

  def multiple_choice?
    question_type == TYPE_MULTIPLE_CHOICE
  end

  def freetext?
    question_type == TYPE_FREETEXT
  end

  def correct_freetext_answer? answer
    freetext? && Regexp.new(freetext_regex).match(answer)
  end

  protected

  def render_markdown_content
    self.content = RenderMarkdown.new(markdown_content).call
  end

  def render_markdown_explanation
    self.explanation = RenderMarkdown.new(markdown_explanation).call
  end
end
