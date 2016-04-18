FactoryGirl.define do
  factory :course do
    title "Some course title"
    subtitle "Some course subtitle"
    sequence(:slug) { |i| "course-slug-#{ i }" }
    markdown_description "Hello world!"
    markdown_long_description "Hello *world*! And everyone *else*"
    visible true
  end
end
