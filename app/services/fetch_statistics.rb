class FetchStatistics
  def initialize
  end

  def fetch_successful_runs
    sql = "SELECT tasks.id, tasks.title, ROUND(CAST(count(CASE WHEN points = 100 THEN task_runs.id END) AS numeric) * 100 / count(*), 2) AS percent FROM tasks INNER JOIN task_runs ON (tasks.id = task_runs.task_id) WHERE task_runs.user_id NOT IN (SELECT user_id FROM roles) GROUP BY tasks.title, tasks.id;"
    return Task.find_by_sql [sql]
  end

end
