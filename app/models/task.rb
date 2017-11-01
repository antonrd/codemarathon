class Task < ApplicationRecord
  module Constants
    TASK_TYPE_IOFILES = "iofiles"
    TASK_TYPE_UNIT = "unit"

    TASK_TYPES = [TASK_TYPE_IOFILES, TASK_TYPE_UNIT]
    TASK_MAX_POINTS = 100.0
  end

  include Constants

  before_save :render_markdown_description
  before_save :render_markdown_solution

  belongs_to :creator, class_name: "User", foreign_key: "creator_id"
  has_many :task_records, dependent: :destroy
  has_many :task_runs, dependent: :destroy
  has_and_belongs_to_many :lessons

  validates :title, presence: true
  validates :markdown_description, presence: true
  validates :task_type, presence: true
  validates :task_type, inclusion: { in: TASK_TYPES }
  validates :creator, presence: true
  validates :memory_limit_kb, presence: true
  validates :time_limit_ms, presence: true

  scope :by_creation, -> { order('created_at ASC') }

  def self.unused_tasks_for lesson
    where.not(id: lesson.tasks.map(&:id))
  end

  def user_stats user
    user_task_runs = user_runs(user)
    puts user_task_runs.map(&:points)
    OpenStruct.new(
      attempts: user_task_runs.count,
      is_solved: (user_task_runs.count > 0 && user_task_runs.map(&:points).max == TASK_MAX_POINTS)
    )
  end

  def user_runs user
    task_runs.where(user: user).newest_first
  end

  def valid_user_runs user
    task_runs.where(user: user).valid_runs
  end

  def task_record_for user
    task_records.find_or_create_by(user: user)
  end

  def is_covered_by? user
    matching_record = task_records.where(user: user).first
    matching_record.present? && matching_record.covered
  end

  def attempts_depleted? user
    user_runs(user).count >= task_record_for(user).runs_limit
  end

  protected

  def render_markdown_description
    self.description = RenderMarkdown.new(markdown_description).call
  end

  def render_markdown_solution
    if markdown_solution.present?
      self.solution = RenderMarkdown.new(markdown_solution).call
    end
  end
end
