class TaskRecord < ActiveRecord::Base
  belongs_to :user
  belongs_to :task
  belongs_to :best_run, foreign_key: 'best_run_id', class_name: "TaskRun"
end
