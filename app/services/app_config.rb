# frozen_string_literal: true

# Centralized configuration object for external service credentials.
# Validates required ENV keys at boot time and provides typed access.
class AppConfig
  REQUIRED_JIRA_KEYS = %w[JIRA_SITE JIRA_USER_EMAIL JIRA_API_TOKEN].freeze
  REQUIRED_AI_KEYS = %w[GEMINI_API_KEY].freeze

  class << self
    def jira_site
      ENV.fetch('JIRA_SITE')
    end

    def jira_user_email
      ENV.fetch('JIRA_USER_EMAIL')
    end

    def jira_api_token
      ENV.fetch('JIRA_API_TOKEN')
    end

    def jira_project_key
      ENV.fetch('JIRA_PROJECT_KEY', 'SUP')
    end

    def jira_assignee_name
      ENV['JIRA_ASSIGNEE_NAME']
    end

    def gemini_api_key
      ENV['GEMINI_API_KEY']
    end

    def validate_jira!
      missing = REQUIRED_JIRA_KEYS.select { |key| ENV[key].blank? }
      return if missing.empty?

      raise KeyError, "Missing required Jira ENV keys: #{missing.join(', ')}"
    end

    def validate_ai!
      missing = REQUIRED_AI_KEYS.select { |key| ENV[key].blank? }
      return if missing.empty?

      Rails.logger.warn "Missing optional AI ENV keys: #{missing.join(', ')}. AI classification disabled."
    end
  end
end
