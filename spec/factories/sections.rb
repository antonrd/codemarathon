FactoryGirl.define do
  factory :section do
    title "Some section title"
    sequence(:position) { |i| i }
    course
    visible true
  end
end
