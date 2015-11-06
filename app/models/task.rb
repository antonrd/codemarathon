class Task < ActiveRecord::Base
  module Constants
    TASK_TYPE_IOFILES = "iofiles"
    TASK_TYPE_PYUNIT = "pyunit"

    TASK_TYPES = [TASK_TYPE_IOFILES, TASK_TYPE_PYUNIT]
  end

  include Constants

  before_save :render_markdown_description

  belongs_to :creator, class_name: "User", foreign_key: "creator_id"
  has_many :task_runs

  validates :title, presence: true
  validates :markdown_description, presence: true
  validates :task_type, presence: true
  validates :task_type, inclusion: { in: TASK_TYPES }
  validates :creator, presence: true

  protected

  def render_markdown_description
    self.description = RenderMarkdown.new(markdown_description).call
  end
end
