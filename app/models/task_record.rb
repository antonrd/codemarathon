class TaskRecord < ActiveRecord::Base
  DEFAULT_MAX_RUNS_LIMIT = 8

  belongs_to :user
  belongs_to :task
  belongs_to :best_run, foreign_key: 'best_run_id', class_name: "TaskRun"

  validates :user, presence: true
  validates :task, presence: true
  validates :best_score, presence: true
  validates :covered, inclusion: { in: [true, false] }
  validates :runs_limit, presence: true
end
