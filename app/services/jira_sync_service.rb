# frozen_string_literal: true

require 'jira-ruby'

# Service to synchronize support tickets with Jira by creating tasks.
class JiraSyncService
  DEFAULT_PROJECT_KEY = 'SUP'
  ISSUE_TYPE_TASK = 'Task'

  DESCRIPTION_TEMPLATE = <<~DESC
    ID: %<id>s
    Customer Type: %<customer_type>s
    Category: %<category>s

    Message:
    %<content>s

    *Processed by Automated Sorting App*
  DESC

  def initialize
    @options = {
      username: ENV['JIRA_USER_EMAIL'],
      password: ENV['JIRA_API_TOKEN'],
      site: ENV['JIRA_SITE'],
      context_path: '',
      auth_type: :basic
    }
  end

  def create_ticket(ticket)
    issue = JIRA::Client.new(@options).Issue.build

    return process_success(ticket, issue.key) if issue.save({ 'fields' => build_fields(ticket) })

    process_failure(ticket)
  rescue StandardError => e
    handle_error(ticket, e)
  end

  private

  def process_success(ticket, key)
    ticket.mark_as_processed(key)
    key
  end

  def process_failure(ticket)
    ticket.mark_as_failed
    false
  end

  def handle_error(ticket, error)
    Rails.logger.error I18n.t('services.jira_sync.errors.failed', id: ticket.id, message: error.message)
    ticket.mark_as_failed
    false
  end

  def build_fields(ticket)
    assignee_name = ENV['JIRA_ASSIGNEE_NAME']
    {
      'project' => { 'key' => ENV.fetch('JIRA_PROJECT_KEY', DEFAULT_PROJECT_KEY) },
      'summary' => I18n.t('services.jira_sync.summary_template', category: ticket.category.to_s.humanize),
      'description' => ticket.jira_description,
      'issuetype' => { 'name' => ISSUE_TYPE_TASK },
      'assignee' => (assignee_name.present? ? { 'name' => assignee_name } : nil)
    }.compact
  end
end
