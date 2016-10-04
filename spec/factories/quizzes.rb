FactoryGirl.define do
  factory :quiz do
    title "Some quiz title"
    association :creator, factory: :user
    maximum_attempts 10
  end
end
