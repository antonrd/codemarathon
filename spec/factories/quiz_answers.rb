FactoryGirl.define do
  factory :quiz_answer do
    association :quiz_question
    markdown_content "**Quiz answer text**"
    correct true
  end
end
