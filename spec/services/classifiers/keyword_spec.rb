# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Classifiers::Keyword do
  describe '.classify' do
    it 'classifies payment flow tickets' do
      expect(described_class.classify('I have a billing issue')).to eq('payment_flow')
    end

    it 'classifies checkout process tickets' do
      expect(described_class.classify('The checkout is slow')).to eq('checkout_process')
    end

    it 'classifies forget password tickets' do
      expect(described_class.classify('I cannot reset my password')).to eq('forget_password_feature')
    end

    it 'classifies cart removal tickets' do
      expect(described_class.classify('Broken delete item from basket button')).to eq('remove_item_from_cart_button')
    end

    it 'classifies cookie modal tickets' do
      expect(described_class.classify('Cookie acceptance popup is annoying')).to eq('cookies_acceptance_modal_window')
    end

    it 'returns uncategorized if no keywords match' do
      expect(described_class.classify('The app is slow')).to eq('uncategorized')
    end
  end
end
