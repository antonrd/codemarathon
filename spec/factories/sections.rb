FactoryGirl.define do
  factory :section do
    title "Some section title"
    sequence(:position) { |i| i }
    course
  end
end
