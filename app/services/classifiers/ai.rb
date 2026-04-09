# frozen_string_literal: true

module Classifiers
  # AI-based classifier using Gemini model to categorize support tickets.
  class Ai
    MODEL = 'gemini-1.5-flash'
    PROMPT_TEMPLATE = <<~PROMPT
      Classify the following support ticket into one of these categories: %<categories>s.
      Return only the category name in lowercase. If none match, return '%<uncategorized>s'.

      Ticket Content:
      %<text>s
    PROMPT

    class << self
      def classify(text)
        return SupportTicket::UNCATEGORIZED if AppConfig.gemini_api_key.blank?

        response = client.generate_content(
          { contents: { role: 'user', parts: { text: generate_prompt(text) } } }
        )

        extract_category(response)
      rescue StandardError => e
        Rails.logger.error I18n.t('services.ai_classification.errors.failed', message: e.message)
        SupportTicket::UNCATEGORIZED
      end

      private

      def client
        Gemini.new(
          credentials: { api_key: AppConfig.gemini_api_key },
          options: { model: MODEL, server_sent_events: true }
        )
      end

      def generate_prompt(text)
        format(
          PROMPT_TEMPLATE,
          categories: SupportTicket::CATEGORIES.join(', '),
          uncategorized: SupportTicket::UNCATEGORIZED,
          text: text
        )
      end

      def extract_category(response)
        category = response.dig('candidates', 0, 'content', 'parts', 0, 'text')&.strip&.downcase
        SupportTicket::CATEGORIES.include?(category) ? category : SupportTicket::UNCATEGORIZED
      end
    end
  end
end
