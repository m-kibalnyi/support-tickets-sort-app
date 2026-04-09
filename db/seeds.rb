# frozen_string_literal: true

Rails.logger.debug 'Seeding support tickets...'

tickets = [
  {
    customer_type: :end_consumer,
    raw_content: <<~TEXT.squish
      I am having trouble with the payment flow. My credit card 4111-2222-3333-4444
      is not being accepted. Please help.
    TEXT
  },
  {
    customer_type: :b2b,
    raw_content: 'Our checkout process is failing for large orders. Contact me at john.doe@company.com'
  },
  {
    customer_type: :end_consumer,
    raw_content: 'I forgot my password and the reset link is not working. My email is consumer@gmail.com'
  },
  {
    customer_type: :end_consumer,
    raw_content: 'I cannot remove an item from my cart. The button seems to be broken.'
  },
  {
    customer_type: :b2b,
    raw_content: 'The cookie acceptance modal window is blocking our dashboard view on mobile devices.'
  },
  {
    customer_type: :end_consumer,
    raw_content: 'Generic complaint about the app speed.'
  }
]

tickets.each do |ticket_attrs|
  SupportTicket.create!(ticket_attrs)
end

Rails.logger.debug "Seeded #{SupportTicket.count} tickets."
