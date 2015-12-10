class SolveTask
  def initialize task, user, params
    @task = task
    @user = user
    @params = params
  end

  def call
    if task_run.persisted?
      response = GraderApi.new.solve_task(task, task_run)
      puts response

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

  attr_reader :task, :user, :params

  def task_run
    @task_run ||= task.task_runs.create(
      user: user,
      source_code: params[:source_code],
      lang: params[:lang],
      status: TaskRun::STATUS_STARTING,
      run_type: TaskRun::TYPE_RUN_TASK,
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
