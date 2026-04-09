# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NightlySupportTicketJob, type: :job do
  let!(:pending_ticket) { create(:support_ticket, status: :pending, raw_content: 'Payment issue') }
  let!(:processed_ticket) { create(:support_ticket, status: :processed, raw_content: 'Already done') }

  describe '#perform' do
    it 'processes only pending tickets via TicketProcessorService' do
      processor_mock = instance_double(TicketProcessorService)
      allow(TicketProcessorService).to receive(:new).and_return(processor_mock)
      allow(processor_mock).to receive(:call)

      described_class.new.perform

      # Should only create processor for the pending ticket, not the processed one
      expect(TicketProcessorService).to have_received(:new).with(pending_ticket).once
      expect(TicketProcessorService).not_to have_received(:new).with(processed_ticket)
    end

    it 'delegates masking, classification, and sync to TicketProcessorService' do
      ticket = create(:support_ticket, status: :pending, raw_content: 'Billing problem with card 4111-2222-3333-4444')

      jira_mock = instance_double(JiraSyncService)
      allow(JiraSyncService).to receive(:new).and_return(jira_mock)
      allow(jira_mock).to receive(:create_ticket) do |t|
        t.mark_as_processed!('SUP-1')
      end

      described_class.new.perform

      ticket.reload
      expect(ticket.filtered_content).to include('****')
      expect(ticket.category).to eq('payment_flow')
      expect(ticket.status).to eq('processed')
    end
  end
end
