FactoryGirl.define do
  factory :task_run do
    user
    task
    source_code "print \'hello world\'"
    lang "ruby"
    status TaskRun::STATUS_SUCCESS
    external_key "14"
    message "success"
    grader_log "some log"
    memory_limit_kb 1024
    time_limit_ms 1000
    run_type TaskRun::TYPE_RUN_TASK
    points 50.0
    display_status "Some Errors"
    compilation_log nil
    has_ml false
    has_tl true
    has_wa true
    has_re false
    re_details nil
  end
end
