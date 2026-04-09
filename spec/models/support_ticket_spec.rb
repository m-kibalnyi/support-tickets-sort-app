# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SupportTicket, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(build(:support_ticket)).to be_valid
    end

    it 'is invalid without raw_content' do
      ticket = build(:support_ticket, raw_content: nil)
      expect(ticket).not_to be_valid
      expect(ticket.errors[:raw_content]).to include("can't be blank")
    end

    describe 'fingerprint' do
      let(:ticket) { build(:support_ticket, raw_content: 'test content') }

      it 'generates fingerprint before validation' do
        ticket.valid?
        expect(ticket.fingerprint).to be_present
      end

      it 'validates uniqueness of fingerprint' do
        create(:support_ticket, raw_content: 'test content')
        duplicate = build(:support_ticket, raw_content: 'test content')
        expect(duplicate).not_to be_valid
        expect(duplicate.errors[:fingerprint]).to include('has already been taken')
      end
    end
  end

  describe 'callbacks' do
    it 'generates a SHA256 fingerprint from raw_content' do
      content = 'test content'
      expected_fingerprint = Digest::SHA256.hexdigest(content)
      ticket = create(:support_ticket, raw_content: content)
      expect(ticket.fingerprint).to eq(expected_fingerprint)
    end
  end

  describe 'enums' do
    it 'defines customer_type with correct values' do
      expect(described_class.customer_types.keys).to match_array(%w[end_consumer b2b])
    end

    it 'defines status with correct values' do
      expect(described_class.statuses.keys).to match_array(%w[pending processing processed failed])
    end
  end

  describe 'constants' do
    it 'defines correct CATEGORIES' do
      expect(described_class::CATEGORIES).to match_array(%w[
                                                           payment_flow
                                                           checkout_process
                                                           forget_password_feature
                                                           remove_item_from_cart_button
                                                           cookies_acceptance_modal_window
                                                         ])
    end

    it 'defines UNCATEGORIZED' do
      expect(described_class::UNCATEGORIZED).to eq('uncategorized')
    end
  end
end
