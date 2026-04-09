# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AppConfig do
  describe '.jira_site' do
    it 'returns JIRA_SITE from ENV' do
      allow(ENV).to receive(:fetch).with('JIRA_SITE').and_return('https://test.atlassian.net')
      expect(described_class.jira_site).to eq('https://test.atlassian.net')
    end
  end

  describe '.jira_project_key' do
    it 'returns JIRA_PROJECT_KEY with default fallback' do
      allow(ENV).to receive(:fetch).with('JIRA_PROJECT_KEY', 'SUP').and_return('PROJ')
      expect(described_class.jira_project_key).to eq('PROJ')
    end
  end

  describe '.gemini_api_key' do
    it 'returns GEMINI_API_KEY from ENV' do
      allow(ENV).to receive(:[]).with('GEMINI_API_KEY').and_return('key-123')
      expect(described_class.gemini_api_key).to eq('key-123')
    end
  end

  describe '.validate_jira!' do
    it 'raises when required Jira keys are missing' do
      allow(ENV).to receive(:[]).and_return(nil)

      expect { described_class.validate_jira! }.to raise_error(KeyError, /JIRA_SITE/)
    end

    it 'does not raise when all required Jira keys are present' do
      allow(ENV).to receive(:[]).with('JIRA_SITE').and_return('https://site.com')
      allow(ENV).to receive(:[]).with('JIRA_USER_EMAIL').and_return('user@test.com')
      allow(ENV).to receive(:[]).with('JIRA_API_TOKEN').and_return('token')

      expect { described_class.validate_jira! }.not_to raise_error
    end
  end

  describe '.validate_ai!' do
    it 'logs a warning when GEMINI_API_KEY is missing' do
      allow(ENV).to receive(:[]).with('GEMINI_API_KEY').and_return(nil)
      allow(Rails.logger).to receive(:warn)

      described_class.validate_ai!

      expect(Rails.logger).to have_received(:warn).with(/GEMINI_API_KEY/)
    end
  end
end
