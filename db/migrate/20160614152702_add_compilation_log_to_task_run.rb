class AddCompilationLogToTaskRun < ActiveRecord::Migration
  def change
    add_column :task_runs, :compilation_log, :text
  end
end
