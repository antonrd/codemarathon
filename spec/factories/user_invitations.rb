FactoryGirl.define do
  factory :user_invitation do
    sequence(:email) { |i| "user-#{ i }@codemarathon.com" }
    used false
  end
end
