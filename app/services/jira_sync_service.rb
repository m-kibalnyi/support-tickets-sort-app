# frozen_string_literal: true

require 'jira-ruby'

# Service to synchronize support tickets with Jira by creating tasks.
class JiraSyncService
  DEFAULT_PROJECT_KEY = 'SUP'
  ISSUE_TYPE_TASK = 'Task'

  def initialize
    @client = JIRA::Client.new(
      username: AppConfig.jira_user_email,
      password: AppConfig.jira_api_token,
      site: AppConfig.jira_site,
      context_path: '',
      auth_type: :basic
    )
  end

  def create_ticket(ticket)
    issue = @client.Issue.build

    return process_success(ticket, issue.key) if issue.save({ 'fields' => build_fields(ticket) })

    process_failure(ticket)
  end

  private

  def process_success(ticket, key)
    ticket.mark_as_processed!(key)
    key
  end

  def process_failure(ticket)
    ticket.mark_as_failed!
    false
  end

  def build_fields(ticket)
    assignee_name = AppConfig.jira_assignee_name
    {
      'project' => { 'key' => AppConfig.jira_project_key },
      'summary' => I18n.t('services.jira_sync.summary_template', category: ticket.category.to_s.humanize),
      'description' => ticket.jira_description,
      'issuetype' => { 'name' => ISSUE_TYPE_TASK },
      'assignee' => (assignee_name.present? ? { 'name' => assignee_name } : nil)
    }.compact
  end
end
