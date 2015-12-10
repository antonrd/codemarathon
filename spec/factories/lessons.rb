FactoryGirl.define do
  factory :lesson do
    title "Some lesson title"
    sequence(:position) { |i| i }
    section
    markdown_content "***Great lesson***"
    visible true
  end
end
