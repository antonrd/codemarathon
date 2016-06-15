module TaskRunDisplayHelper
  def task_run_display_class task_run
    if task_run.accepted?
      "success"
    elsif task_run.with_errors?
      "warning"
    end
  end
end
