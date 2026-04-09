# frozen_string_literal: true

# Service responsible for processing a support ticket:
# masking PII, classifying, and syncing to Jira.
class TicketProcessorService
  def initialize(ticket, jira_service: JiraSyncService.new, masker: DataMasker)
    @ticket = ticket
    @jira_service = jira_service
    @masker = masker
  end

  def call
    @ticket.mark_as_processing!
    classify_ticket
    @jira_service.create_ticket(@ticket)
  rescue StandardError => e
    Rails.logger.error I18n.t('services.ticket_processor.errors.failed', id: @ticket.id, message: e.message)
    @ticket.mark_as_failed!
    false
  end

  private

  def classify_ticket
    @ticket.filtered_content = @masker.mask(@ticket.raw_content)
    @ticket.category = auto_classify(@ticket.filtered_content)
    @ticket.save!
  end

  def auto_classify(content)
    category = Classifiers::Keyword.classify(content)
    category = Classifiers::Ai.classify(content) if category == SupportTicket::UNCATEGORIZED
    category
  end
end
