FactoryGirl.define do
  factory :task do
    title "Some task title"
    task_type Task::TASK_TYPE_IOFILES
    markdown_description "**Hello world**"
    association :creator, factory: :user
    visible true
    external_key "14"
    memory_limit_kb 1024
    time_limit_ms 1000
  end
end
