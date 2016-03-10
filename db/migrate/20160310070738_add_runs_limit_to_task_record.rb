class AddRunsLimitToTaskRecord < ActiveRecord::Migration
  def change
    add_column :task_records, :runs_limit, :integer, null: false, default: TaskRecord::DEFAULT_MAX_RUNS_LIMIT
  end
end
