# frozen_string_literal: true

# Represents a customer support ticket with categorization and filtering logic.
class SupportTicket < ApplicationRecord
  encrypts :raw_content
  encrypts :filtered_content
  encrypts :payload

  enum :customer_type, { end_consumer: 0, b2b: 1 }
  enum :status, { pending: 'pending', processing: 'processing', processed: 'processed', failed: 'failed' },
       default: 'pending'

  validates :raw_content, presence: true
  validates :fingerprint, presence: true, uniqueness: true

  before_validation :generate_fingerprint, on: :create

  UNCATEGORIZED = 'uncategorized'

  CATEGORIES = %w[
    payment_flow
    checkout_process
    forget_password_feature
    remove_item_from_cart_button
    cookies_acceptance_modal_window
  ].freeze

  DESCRIPTION_TEMPLATE = <<~DESC
    ID: %<id>s
    Customer Type: %<customer_type>s
    Category: %<category>s

    Message:
    %<content>s

    *Processed by Automated Sorting App*
  DESC

  def generate_fingerprint
    self.fingerprint = Digest::SHA256.hexdigest(raw_content) if raw_content.present?
  end

  def jira_description
    format(
      DESCRIPTION_TEMPLATE,
      id: id,
      customer_type: customer_type,
      category: category,
      content: filtered_content
    )
  end

  def mark_as_processing!
    update!(status: :processing)
  end

  def mark_as_processed!(jira_key)
    update!(jira_ticket_key: jira_key, status: :processed)
  end

  def mark_as_failed!
    update!(status: :failed)
  end
end
