class AddRunTypeToTaskRuns < ActiveRecord::Migration
  def change
    add_column :task_runs, :run_type, :string

    TaskRun.find_each do |task_run|
      task_run.update_attributes(run_type: TaskRun::TYPE_RUN_TASK)
    end

    change_column_null(:task_runs, :run_type, false)
  end
end
