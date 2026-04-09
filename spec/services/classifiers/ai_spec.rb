# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Classifiers::Ai do
  describe '.classify' do
    let(:gemini_client) { double('Gemini') }

    before do
      allow(AppConfig).to receive(:gemini_api_key).and_return('test-key')
    end

    it 'returns the AI-classified category when valid' do
      response = {
        'candidates' => [
          { 'content' => { 'parts' => [{ 'text' => "payment_flow\n" }] } }
        ]
      }

      allow(Gemini).to receive(:new).and_return(gemini_client)
      allow(gemini_client).to receive(:generate_content).and_return(response)

      expect(described_class.classify('some ticket text')).to eq('payment_flow')
    end

    it 'returns uncategorized when AI returns an unknown category' do
      response = {
        'candidates' => [
          { 'content' => { 'parts' => [{ 'text' => 'unknown_category' }] } }
        ]
      }

      allow(Gemini).to receive(:new).and_return(gemini_client)
      allow(gemini_client).to receive(:generate_content).and_return(response)

      expect(described_class.classify('some ticket text')).to eq('uncategorized')
    end

    it 'returns uncategorized when GEMINI_API_KEY is missing' do
      allow(AppConfig).to receive(:gemini_api_key).and_return(nil)

      expect(described_class.classify('some ticket text')).to eq('uncategorized')
    end

    it 'returns uncategorized when the API response is malformed' do
      response = { 'candidates' => [] }

      allow(Gemini).to receive(:new).and_return(gemini_client)
      allow(gemini_client).to receive(:generate_content).and_return(response)

      expect(described_class.classify('some ticket text')).to eq('uncategorized')
    end

    it 'returns uncategorized and logs error on API failure' do
      allow(Gemini).to receive(:new).and_return(gemini_client)
      allow(gemini_client).to receive(:generate_content).and_raise(StandardError, 'API timeout')
      allow(Rails.logger).to receive(:error)

      expect(described_class.classify('some ticket text')).to eq('uncategorized')
      expect(Rails.logger).to have_received(:error).with(/AI Classification failed: API timeout/)
    end
  end
end
