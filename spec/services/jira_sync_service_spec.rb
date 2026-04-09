# frozen_string_literal: true

require 'rails_helper'
require 'webmock/rspec'

RSpec.describe JiraSyncService do
  let(:ticket) { create(:support_ticket, category: :payment_flow, filtered_content: 'Masked message') }
  let(:service) { described_class.new }

  before do
    allow(AppConfig).to receive(:jira_user_email).and_return('test@example.com')
    allow(AppConfig).to receive(:jira_api_token).and_return('token')
    allow(AppConfig).to receive(:jira_site).and_return('https://test.atlassian.net')
    allow(AppConfig).to receive(:jira_assignee_name).and_return('John Peterson')
    allow(AppConfig).to receive(:jira_project_key).and_return('SUP')
  end

  describe '#create_ticket' do
    it 'successfully creates a Jira issue' do
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
