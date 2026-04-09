# frozen_string_literal: true

FactoryBot.define do
  factory :support_ticket do
    customer_type { :end_consumer }
    raw_content { 'I need help with my payment' }
    status { :pending }
    category { nil }
  end
end
