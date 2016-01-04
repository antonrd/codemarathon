FactoryGirl.define do
  factory :lesson_record do
    views 10
    covered false

    user
    lesson
    classroom
  end
end
