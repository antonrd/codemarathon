FactoryGirl.define do
  factory :classroom do
    name "Classroom name"
    sequence(:slug) { |i| "classroom-slug-#{ i }" }

    course
  end
end
