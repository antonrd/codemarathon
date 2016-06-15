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
        run_message = "Grader Error"
      end
      run.update_attributes(status: TaskRun::STATUS_ERROR,
                            display_status: compute_display_status(response, 0),
                            message: response["run_message"],
                            grader_log: response["run_log"],
                            points: 0)
    end
  end

  def update_run(run:, response:, compute_points: false)
    points = 0.0
    if compute_points && response["run_status"] == TaskRun::STATUS_SUCCESS
      points = compute_points(response)
    end

    run.update_attributes(status: response["run_status"],
                          display_status: compute_display_status(response, points),
                          message: response["run_message"],
                          grader_log: response["run_log"],
                          points: points,
                          time_limit_ms: compute_max_run_time(response),
                          memory_limit_kb: compute_max_run_memory(response),
                          compilation_log: response["compilation"],
                          has_ml: has_ml(response),
                          has_tl: has_tl(response),
                          has_wa: has_wa(response),
                          has_re: has_re(response),
                          re_details: re_details(response))
  end

  def compute_display_status(response, points)
    if response["run_status"] == TaskRun::STATUS_SUCCESS
      if points == Task::TASK_MAX_POINTS
        "Accepted"
      else
        "Some Errors"
      end
    else
      response["run_status"].titlecase
    end
  end

  def compute_points(response)
    test_cases_count = response["test_cases"].count
    return 0.0 if test_cases_count == 0

    passed_test_cases_count = response["test_cases"].
      count { |test_case| test_case["status"] == "ok" }

    puts "Passing test cases #{ passed_test_cases_count } out of #{ test_cases_count }"
    return passed_test_cases_count * Task::TASK_MAX_POINTS / test_cases_count
  end

  def compute_max_run_time(response)
    if response["test_cases"].present?
      response["test_cases"].map { |t| t["used_time"] }.max * 1000
    else
      0.0
    end
  end

  def compute_max_run_memory(response)
    if response["test_cases"].present?
      response["test_cases"].map { |t| t["used_memory"] }.max / 1024
    else
      0.0
    end
  end

  def has_ml(response)
    response["test_cases"].present? && response["test_cases"].any? { |t| t["status"] == "ml" }
  end

  def has_tl(response)
    response["test_cases"].present? && response["test_cases"].any? { |t| t["status"] == "tl" }
  end

  def has_wa(response)
    response["test_cases"].present? && response["test_cases"].any? { |t| t["status"] == "wa" }
  end

  def has_re(response)
    response["test_cases"].present? && response["test_cases"].any? { |t| t["status"] == "re" }
  end

  def re_details(response)
    return unless response["test_cases"].present?

    re_logs = []
    response["test_cases"].each do |test_case|
      if test_case["status"] == "re"
        re_log = test_case["execution"].strip
        re_logs << re_log unless re_logs.include?(re_log)
      end
    end

    re_logs.join("\n\n--------------------------------\n\n")
  end
end
