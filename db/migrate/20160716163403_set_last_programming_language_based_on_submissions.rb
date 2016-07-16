class SetLastProgrammingLanguageBasedOnSubmissions < ActiveRecord::Migration
  def change
    User.find_each do |user|
      latest_task_run = user.task_runs.newest_first.first
      if latest_task_run.present?
        user.update_attributes(last_programming_language: latest_task_run.lang)
      end
    end
  end
end
