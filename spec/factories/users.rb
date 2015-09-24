FactoryGirl.define do
  factory :user do
    sequence(:email) { |i| "user-#{ i }@codemarathon.com" }
    sequence(:name) { |i| "Some Name-#{ i }" }
    password "some_test_pass"
  end
end
