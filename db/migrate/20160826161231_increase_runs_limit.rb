class IncreaseRunsLimit < ActiveRecord::Migration
  def change
    change_column_default :task_records, :runs_limit, TaskRecord::DEFAULT_MAX_RUNS_LIMIT

    TaskRecord.where(runs_limit: 5).update_all(runs_limit: TaskRecord::DEFAULT_MAX_RUNS_LIMIT)
  end
end
