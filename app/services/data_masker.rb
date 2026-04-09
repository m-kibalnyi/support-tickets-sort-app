# frozen_string_literal: true

# Service for masking sensitive information (e.g., PII, credit cards) in support tickets.
class DataMasker
  MASK = '****'

  # Regex patterns for sensitive data
  PATTERNS = {
    # Partial CC: Show first 4 and last 4
    credit_card: /\b(\d{4})[ -]*?(\d[ -]*?){5,8}(\d{4})\b/,
    email: /\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}\b/i,
    ssn: /\b\d{3}-\d{2}-\d{4}\b/,
    # CVV/CVC with context
    cvv: /(?i:cvv|cvc|security code|cid)[\s:]*(\d{3,4})\b/,
    # Physical Address (Heuristic)
    address: /\d+\s+[A-Z][a-z]+(?:\s+[A-Z][a-z]+)*\s+
                (?:Street|St|Avenue|Ave|Road|Rd|Way|Drive|Dr|Lane|Ln|PL|Boulevard|Blvd|Court|Ct)\b/x
  }.freeze

  CC_MASK = '********'

  class << self
    def mask(text)
      return text if text.blank?

      text.dup.tap do |masked_text|
        mask_credit_card!(masked_text)
        mask_cvv!(masked_text)
        mask_generic_pii!(masked_text)
      end
    end

    private

    def mask_credit_card!(text)
      text.gsub!(PATTERNS[:credit_card]) { "#{::Regexp.last_match(1)}#{CC_MASK}#{::Regexp.last_match(3)}" }
    end

    def mask_cvv!(text)
      text.gsub!(PATTERNS[:cvv]) { |match| match.gsub(/\d{3,4}/, MASK) }
    end

    def mask_generic_pii!(text)
      %i[email ssn address].each { |type| text.gsub!(PATTERNS[type], MASK) }
    end
  end
end
