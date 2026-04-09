# frozen_string_literal: true

FactoryBot.define do
  factory :support_ticket do
    customer_type { :end_consumer }
    sequence(:raw_content) { |n| "I need help with my payment ##{n}" }
    status { :pending }
    category { nil }
  end
end
