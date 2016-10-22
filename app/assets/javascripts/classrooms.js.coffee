window.Codemarathon ||= {}

Codemarathon.observeTaskRun = (classroom_id, lesson_id, task_id, task_run_id) ->
  setTimeout(Codemarathon.updateTaskRunPartial(
    classroom_id, lesson_id, task_id, task_run_id), 3000);

Codemarathon.updateTaskRunPartial = (classroom_id, lesson_id, task_id, task_run_id) ->
  () ->
    $.ajax(url: "/classrooms/" + classroom_id + "/lesson/" + lesson_id +
      "/task/" + task_id + "/task_run/" + task_run_id)
