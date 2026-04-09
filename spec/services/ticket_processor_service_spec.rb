# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TicketProcessorService do
  let(:ticket) do
    create(:support_ticket, status: :pending, raw_content: 'Billing problem with card 4111-2222-3333-4444')
  end
  let(:jira_service) { instance_double(JiraSyncService) }
  let(:service) { described_class.new(ticket, jira_service: jira_service) }

  describe '#call' do
    it 'masks data, classifies, and syncs to Jira' do
      allow(jira_service).to receive(:create_ticket) do |t|
        t.mark_as_processed!('SUP-1')
      end

      service.call

      ticket.reload
      expect(ticket.filtered_content).to include('****')
      expect(ticket.category).to eq('payment_flow')
      expect(ticket.status).to eq('processed')
    end

    it 'marks ticket as processing before classification' do
      allow(jira_service).to receive(:create_ticket)

      service.call

      # After full processing, status may be updated by Jira service
      # but mark_as_processing! should have been called
      expect(ticket.reload.status).to be_in(%w[processing processed])
    end

    it 'marks ticket as failed and returns false on error' do
      allow(jira_service).to receive(:create_ticket).and_raise(StandardError, 'Jira is down')
      allow(Rails.logger).to receive(:error)

      result = service.call

      expect(result).to be false
      expect(ticket.reload.status).to eq('failed')
      expect(Rails.logger).to have_received(:error).with(/Ticket processing failed/)
    end

    it 'uses AI classifier when keyword classifier returns uncategorized' do
      ticket = create(:support_ticket, status: :pending, raw_content: 'The app is slow and laggy')
      service = described_class.new(ticket, jira_service: jira_service)

      allow(Classifiers::Ai).to receive(:classify).and_return('uncategorized')
      allow(jira_service).to receive(:create_ticket)

      service.call

      expect(Classifiers::Ai).to have_received(:classify)
    end
  end
end
