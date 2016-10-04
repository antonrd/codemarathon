FactoryGirl.define do
  factory :quiz_answer do
    association :quiz_question
    content "Quiz answer text"
    correct true
  end
end
