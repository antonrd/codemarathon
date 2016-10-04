FactoryGirl.define do
  factory :quiz_attempt do
    association :quiz
    association :user
    score 1.5
    answers_json "{}"
  end
end
