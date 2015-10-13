FactoryGirl.define do
  factory :course do
    title "Some course title"
    markdown_description "Hello world!"
    markdown_long_description "Hello *world*! And everyone *else*"
  end
end
