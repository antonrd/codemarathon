FactoryGirl.define do
  factory :user do
    sequence(:email) { |i| "user-#{ i }@codemarathon.com" }
    sequence(:name) { |i| "Some Name-#{ i }" }
    password "some_test_pass"

    trait :teacher do
      after(:create) do |user, evaluator|
        create(:role, :teacher, user: user)
      end
    end

    trait :admin do
      after(:create) do |user, evaluator|
        create(:role, :admin, user: user)
      end
    end
  end
end
