class AddDisableTaskSubmissionsToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :disable_task_submissions, :boolean, default: false, null: false
  end
end
