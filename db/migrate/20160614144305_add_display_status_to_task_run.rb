class AddDisplayStatusToTaskRun < ActiveRecord::Migration
  def change
    add_column :task_runs, :display_status, :string

    TaskRun.find_each do |task_run|
      task_run.update_attribute(:display_status, display_status(task_run))
    end

    change_column_null :task_runs, :display_status, false
  end

  private

  def display_status task_run
    if task_run.status == TaskRun::STATUS_SUCCESS
      if task_run.points == Task::TASK_MAX_POINTS
        "Accepted"
      else
        "Some Errors"
      end
    else
      task_run.status.titlecase
    end
  end
end
