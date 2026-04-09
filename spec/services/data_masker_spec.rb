# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DataMasker do
  describe '.mask' do
    it 'masks credit card numbers partially (BIN + Last4)' do
      text = 'My card is 4111-2222-3333-4444'
      expect(described_class.mask(text)).to eq('My card is 4111********4444')
    end

    it 'masks CVV numbers when context is present' do
      expect(described_class.mask('CVV: 123')).to eq('CVV: ****')
      expect(described_class.mask('cvc 456')).to eq('cvc ****')
    end

    it 'masks physical addresses' do
      text = 'My address is 123 Main Street'
      expect(described_class.mask(text)).to eq('My address is ****')
    end

    it 'masks email addresses' do
      text = 'Contact me at test@example.com please'
      expect(described_class.mask(text)).to eq('Contact me at **** please')
    end

    it 'masks multiple sensitive items' do
      text = 'Email test@example.com and card 4111222233334444'
      expect(described_class.mask(text)).to eq('Email **** and card 4111********4444')
    end

    it 'does not change normal text' do
      text = 'Hello world'
      expect(described_class.mask(text)).to eq('Hello world')
    end
  end
end
