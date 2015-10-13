FactoryGirl.define do
  factory :lesson do
    title "Some lesson title"
    sequence(:position) { |i| i }
    section
  end
end
