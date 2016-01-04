FactoryGirl.define do
  factory :task_record do
    user
    task
    best_score 50.0
    association :best_run, factory: :task_run
    covered true
  end
end
