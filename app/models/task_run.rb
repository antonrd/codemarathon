class TaskRun < ApplicationRecord
  module Constants
    # TYPE_NEW_TASK = "new_task"
    TYPE_UPDATE_TASK = "update_task"
    TYPE_RUN_TASK = "run_task"
    TYPE_UPDATE_CHECKER = "update_checker"

    STATUS_STARTING = "starting"
    STATUS_PENDING = "pending"
    STATUS_RUNNING = "running"
    STATUS_CE = "compilation error"
    STATUS_ERROR = "unknown error"
    STATUS_GRADER_ERROR = "grader error"
    STATUS_SUCCESS = "finished"

    PROGRAMMING_LANGS = [['C++', 'cpp'], ['Java', 'java'], ['Python', 'python'], ['Ruby', 'ruby']]
  end

  include Constants

  belongs_to :task
  belongs_to :user

  validates :task, presence: true
  validates :user, presence: true
  validates :lang, presence: true
  validates :status, presence: true
  validates :memory_limit_kb, presence: true
  validates :time_limit_ms, presence: true
  validates :points, presence: true

  scope :pending, -> { where(status: [STATUS_PENDING, STATUS_RUNNING]) }
  scope :valid_runs, -> { where.not(status: [STATUS_ERROR, STATUS_GRADER_ERROR]) }
  scope :earliest_updated_first, -> { order("updated_at asc") }
  scope :latest_updated_first, -> { order("updated_at desc") }
  scope :newest_first, -> { order("created_at desc") }

  def with_errors?
    (status == TaskRun::STATUS_SUCCESS && points < Task::TASK_MAX_POINTS) ||
      [TaskRun::STATUS_CE, TaskRun::STATUS_ERROR, TaskRun::STATUS_GRADER_ERROR].include?(status)
  end

  def in_progress?
    [TaskRun::STATUS_STARTING, TaskRun::STATUS_PENDING, TaskRun::STATUS_RUNNING].include?(status)
  end

  def accepted?
    status == TaskRun::STATUS_SUCCESS && points == Task::TASK_MAX_POINTS
  end
end
