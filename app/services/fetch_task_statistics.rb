class FetchTaskStatistics
  def call
    runs_stats_by_task = {}
    stats_by_task_and_language.each do |runs_stats|
      unless runs_stats_by_task.has_key?(runs_stats.id)
        runs_stats_by_task[runs_stats.id] = { title: runs_stats.title,
          all_runs: 0, successful_runs: 0 }
      end

      runs_stats_by_task[runs_stats.id][:successful_runs] += runs_stats.success_count
      runs_stats_by_task[runs_stats.id][:all_runs] += runs_stats.all_count

      if runs_stats_by_task[runs_stats.id][:all_runs] > 0
        runs_stats_by_task[runs_stats.id][:success_percent] =
          (runs_stats_by_task[runs_stats.id][:successful_runs].to_f /
            runs_stats_by_task[runs_stats.id][:all_runs] * 100).round(2)
      else
        runs_stats_by_task[runs_stats.id][:success_percent] = 0.0
      end

      runs_stats_by_task[runs_stats.id]["#{ runs_stats.lang }_successful_runs".to_sym] = runs_stats.success_count
      runs_stats_by_task[runs_stats.id]["#{ runs_stats.lang }_all_runs".to_sym] = runs_stats.all_count

      if runs_stats.success_count.present? && runs_stats.all_count.present? && runs_stats.all_count > 0
        runs_stats_by_task[runs_stats.id]["#{ runs_stats.lang }_success_percent".to_sym] =
          (runs_stats.success_count.to_f / runs_stats.all_count * 100).round(2)
      else
        runs_stats_by_task[runs_stats.id]["#{ runs_stats.lang }_success_percent".to_sym] = 0.0
      end
    end

    runs_stats_by_task
  end

  def stats_by_task_and_language
    @stats_by_task_and_language ||= Task.joins("LEFT JOIN task_runs ON tasks.id = task_runs.task_id").
      select("tasks.id, tasks.title, task_runs.lang, count(CASE WHEN points = 100 THEN 1 ELSE NULL END) AS success_count, count(*) as all_count").
      where("task_runs.user_id NOT IN (SELECT user_id FROM roles)").
      group("tasks.title, tasks.id, task_runs.lang").
      order("success_count desc")
  end
end
