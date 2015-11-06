class AddPointsToTaskRun < ActiveRecord::Migration
  def change
    add_column :task_runs, :points, :float
  end
end
