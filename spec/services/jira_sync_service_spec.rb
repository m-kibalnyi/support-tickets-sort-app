# frozen_string_literal: true

require 'rails_helper'
require 'webmock/rspec'

RSpec.describe JiraSyncService do
  let(:ticket) { create(:support_ticket, category: :payment_flow, filtered_content: 'Masked message') }
  let(:service) { described_class.new }

  before do
    allow(ENV).to receive(:[]).with('JIRA_USER_EMAIL').and_return('test@example.com')
    allow(ENV).to receive(:[]).with('JIRA_API_TOKEN').and_return('token')
    allow(ENV).to receive(:[]).with('JIRA_SITE').and_return('https://test.atlassian.net')
    allow(ENV).to receive(:[]).with('JIRA_PROJECT_KEY').and_return('SUP')
    allow(ENV).to receive(:[]).with('JIRA_ASSIGNEE_NAME').and_return('John Peterson')
  end

  describe '#create_ticket' do
    it 'successfully creates a Jira issue' do
      # Use double instead of instance_double for Jira resources to handle dynamic methods
      client_mock = instance_double(JIRA::Client)
      issue_mock = double('JiraIssue')

      allow(JIRA::Client).to receive(:new).and_return(client_mock)
      allow(client_mock).to receive_message_chain(:Issue, :build).and_return(issue_mock)
      allow(issue_mock).to receive(:save).and_return(true)
      allow(issue_mock).to receive(:key).and_return('SUP-123')

      result = service.create_ticket(ticket)

      expect(result).to eq('SUP-123')
      expect(ticket.reload.status).to eq('processed')
      expect(ticket.jira_ticket_key).to eq('SUP-123')
    end

    it 'handles failure gracefully' do
      client_mock = instance_double(JIRA::Client)
      issue_mock = double('JiraIssue')

      allow(JIRA::Client).to receive(:new).and_return(client_mock)
      allow(client_mock).to receive_message_chain(:Issue, :build).and_return(issue_mock)
      allow(issue_mock).to receive(:save).and_return(false)

      result = service.create_ticket(ticket)

      expect(result).to be_falsey
      expect(ticket.reload.status).to eq('failed')
    end
  end
end
