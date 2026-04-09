# frozen_string_literal: true

# Background job to process pending support tickets nightly.
class NightlySupportTicketJob < ApplicationJob
  queue_as :default

  def perform
    tickets = SupportTicket.where(status: :pending)

    tickets.find_each do |ticket|
      TicketProcessorService.new(ticket).call
    end
  end
end
