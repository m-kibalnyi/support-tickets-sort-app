# frozen_string_literal: true

# Background job to process pending support tickets nightly.
class NightlySupportTicketJob < ApplicationJob
  queue_as :default

  def perform
    tickets = SupportTicket.where(status: :pending)
    jira_sync = JiraSyncService.new

    tickets.find_each do |ticket|
      process_ticket(ticket, jira_sync)
    end
  end

  private

  def process_ticket(ticket, jira_sync)
    ticket.mark_as_processing
    ticket.process_classification
    jira_sync.create_ticket(ticket)
  rescue StandardError => e
    Rails.logger.error "Error processing ticket #{ticket.id}: #{e.message}"
    ticket.mark_as_failed
  end
end
