# TODO: Maybe rename to something like CreateTaskRun, to cover the
# case when a checker update is issued.
class SolveTask
  def initialize task, user, params, run_type=TaskRun::TYPE_RUN_TASK
    @task = task
    @user = user
    @params = params
    @run_type = run_type
  end

  def call
    if task_run.persisted?
      if run_type == TaskRun::TYPE_RUN_TASK
        response = GraderApi.new.solve_task(task, task_run)
      elsif run_type == TaskRun::TYPE_UPDATE_CHECKER
        response = GraderApi.new.update_checker(task, task_run)
      else
        return fail("Unknown run type")
      end

      if response["status"] == 0
        task_run.update_attributes(
          external_key: response["run_id"],
          status: TaskRun::STATUS_PENDING,
          message: response["message"])
      else
        task_run.update_attributes(
          status: TaskRun::STATUS_GRADER_ERROR,
          message: "Grader error")
      end

      if response["status"] == 0
        success
      else
        fail(response["message"])
      end
    else
      fail("Unable to create a task run: #{ task_run.errors.full_messages.to_sentence }")
    end
  end

  protected

  attr_reader :task, :user, :params, :run_type

  def task_run
    @task_run ||= task.task_runs.create(
      user: user,
      source_code: params[:source_code],
      lang: params[:lang],
      status: TaskRun::STATUS_STARTING,
      display_status: "Starting",
      run_type: run_type,
      memory_limit_kb: 0,
      time_limit_ms: 0)
  end

  def fail(message)
    OpenStruct.new(status: false, message: message)
  end

  def success
    OpenStruct.new(status: true, message: "Task run submitted successfully")
  end
end
