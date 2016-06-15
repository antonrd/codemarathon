window.Codemarathon ||= {}

Codemarathon.observeTaskRun = (task_run_id) ->
  setTimeout(Codemarathon.updateTaskRunPartial(task_run_id), 2000);

Codemarathon.updateTaskRunPartial = (task_run_id) ->
  () ->
    $.ajax(url: "/task_runs/" + task_run_id)

