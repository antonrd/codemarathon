FactoryGirl.define do
  factory :role do
    user

    trait :teacher do
      role_type User::ROLE_TEACHER
    end

    trait :admin do
      role_type User::ROLE_ADMIN
    end
  end
end
