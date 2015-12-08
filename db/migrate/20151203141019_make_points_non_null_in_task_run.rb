class MakePointsNonNullInTaskRun < ActiveRecord::Migration
  def change
    TaskRun.where(points: nil).update_all(points: 0.0)
    change_column_default(:task_runs, :points, 0.0)
    change_column_null(:task_runs, :points, false)
  end
end
