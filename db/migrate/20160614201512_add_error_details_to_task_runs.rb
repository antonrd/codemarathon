class AddErrorDetailsToTaskRuns < ActiveRecord::Migration
  def change
    add_column :task_runs, :has_ml, :boolean, default: false, null: false
    add_column :task_runs, :has_tl, :boolean, default: false, null: false
    add_column :task_runs, :has_wa, :boolean, default: false, null: false
    add_column :task_runs, :has_re, :boolean, default: false, null: false
    add_column :task_runs, :re_details, :text

    TaskRun.find_each do |task_run|
      has_ml = task_run.message.present? && task_run.message.include?("ml")
      has_tl = task_run.message.present? && task_run.message.include?("tl")
      has_wa = task_run.message.present? && task_run.message.include?("wa")
      has_re = task_run.message.present? && task_run.message.include?("re")
      task_run.update_attributes(has_ml: has_ml, has_tl: has_tl, has_wa: has_wa, has_re: has_re)
    end
  end
end
