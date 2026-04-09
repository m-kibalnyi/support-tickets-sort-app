# frozen_string_literal: true

# Module for classifying support tickets based on predefined keyword patterns.
module Classifiers
  # Keyword-based classifier for categorizing support tickets.
  class Keyword
    KEYWORDS = {
      'payment_flow' => [/payment/i, /billing/i, /credit card/i, /invoice/i, /charge/i],
      'checkout_process' => [/checkout/i, /purchase/i, /buy/i, /order/i, /payment process/i],
      'forget_password_feature' => [/password/i, /login/i, /reset/i, /access/i, /account/i],
      'remove_item_from_cart_button' => [/remove/i, /delete/i, /cart/i, /basket/i, /empty/i],
      'cookies_acceptance_modal_window' => [/cookie/i, /privacy/i, /modal/i, /popup/i, /acceptance/i]
    }.freeze

    def self.classify(text)
      category, = KEYWORDS.find do |_name, regexes|
        regexes.any? { |regex| text.match?(regex) }
      end
      category || SupportTicket::UNCATEGORIZED
    end
  end
end
