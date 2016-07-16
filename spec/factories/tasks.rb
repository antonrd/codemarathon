FactoryGirl.define do
  factory :task do
    title "Some task title"
    task_type Task::TASK_TYPE_IOFILES
    markdown_description "**Task description**"
    association :creator, factory: :user
    visible true
    external_key "14"
    memory_limit_kb 1024
    time_limit_ms 1000
    cpp_boilerplate "int foo(int value) { // write code here }"
    cpp_wrapper "int main() { foo(); return 0; }"
    java_boilerplate "java boilerplate"
    java_wrapper "java wrapper"
  end
end
