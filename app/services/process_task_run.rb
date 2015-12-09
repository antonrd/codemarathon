class ProcessTaskRun
  def initialize grader_api
    @grader_api = grader_api
  end

  def call
    if run = TaskRun.pending.earliest_updated_first.first
      if run.external_key.present?
        puts "Inspecting run with ID: #{ run.id }"
        response = grader_api.get_run_status(run)
        puts "Run status update: #{ response }"

        process_response(run: run, response: response)
      else
        run.update_attribute(:updated_at, Time.now)
      end

      run
    end
  end

  protected

  attr_reader :grader_api

  def process_response(run:, response:)
    if response["status"] == 0
      if run.run_type == TaskRun::TYPE_RUN_TASK
        update_run(run: run, response: response, compute_points: true)
        UpdateUserWithTaskRun.new(run).call
      elsif run.run_type == TaskRun::TYPE_UPDATE_CHECKER
        update_run(run: run, response: response, compute_points: false)
      else
        run.update_attributes(status: TaskRun::STATUS_ERROR,
                              message: "Unknown type of task run: #{ run.run_type }")
      end
    else
      puts "Failed to update the status of run #{ run.id } with external key #{ run.external_key }. Error: #{ response["message"] }"
      if response.has_key?("run_message")
        run_message = response["run_message"]
      else
        run_message = "Grader error"
      end
      run.update_attributes(status: TaskRun::STATUS_ERROR,
                            message: response["run_message"],
                            grader_log: response["run_log"],
                            points: 0)
    end
  end

  def update_run(run:, response:, compute_points: false)
    points = 0.0
    if compute_points && response["run_status"] == TaskRun::STATUS_SUCCESS
      points = compute_points(response["run_message"])
    end

    run.update_attributes(status: response["run_status"],
                          message: response["run_message"],
                          grader_log: response["run_log"],
                          points: points)
  end

  def compute_points(status_msg)
    arr = status_msg.split(" ")
    return 0.0 if arr.empty?
    points = arr.count{ |st| st == 'ok' }
    puts "Matching test cases #{ points }"
    return points * Task::TASK_MAX_POINTS / arr.size
  end

end
