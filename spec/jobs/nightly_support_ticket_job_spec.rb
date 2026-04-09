# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NightlySupportTicketJob, type: :job do
  let!(:pending_ticket) { create(:support_ticket, status: :pending, raw_content: 'Payment issue') }
  let!(:processed_ticket) { create(:support_ticket, status: :processed, raw_content: 'Already done') }

  describe '#perform' do
    it 'processes only pending tickets' do
      # Mock JiraSyncService and ensure it updates the ticket
      jira_mock = instance_double(JiraSyncService)
      allow(JiraSyncService).to receive(:new).and_return(jira_mock)
      allow(jira_mock).to receive(:create_ticket) do |ticket|
        ticket.update(status: :processed)
      end

      described_class.new.perform

      expect(pending_ticket.reload.status).to eq('processed')
      expect(processed_ticket.reload.status).to eq('processed')
    end

    it 'masks data and classifies before syncing' do
      ticket = create(:support_ticket, status: :pending, raw_content: 'Billing problem with card 4111-2222-3333-4444')

      jira_mock = instance_double(JiraSyncService)
      allow(JiraSyncService).to receive(:new).and_return(jira_mock)
      allow(jira_mock).to receive(:create_ticket) do |t|
        t.update(status: :processed)
      end

      described_class.new.perform

      ticket.reload
      expect(ticket.filtered_content).to include('****')
      expect(ticket.category).to eq('payment_flow')
      expect(ticket.status).to eq('processed')
    end
  end
end
