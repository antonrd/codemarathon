class AddPublicToTaskRun < ActiveRecord::Migration[5.0]
  def change
    add_column :task_runs, :show_source_code, :boolean, default: false, null: false
    add_column :task_runs, :show_user_name, :boolean, default: false, null: false

    TaskRun.update_all(show_source_code: true)
  end
end
