# Support Ticket Sorting App - Documentation

## Overview
This Ruby on Rails application automatically gathers support tickets, masks sensitive PII data, classifies them into categories using either keyword matching or Gemini AI, and syncs them as tickets to a Jira backlog.

## Key Features
- **Automated Processing**: Nightly job via Solid Queue processes all pending tickets.
- **Privacy First**: DataMasker service scrubs Credit Cards, Emails, and SSNs before data leaves the system.
- **Hybrid Classification**: Uses fast Keyword matching first, falling back to advanced AI (Gemini) if needed.
- **Jira Integration**: Automatically creates Jira tasks with project/assignee details.

## Setup Instructions

1. **Prerequisites**:
   - Ruby 3.2+
   - Rails 7.2+ / 8.0
   - SQLite3

2. **Environment Variables**:
   Create a `.env` file with the following variables:
   ```env
   # Jira Configuration
   JIRA_SITE=https://your-domain.atlassian.net
   JIRA_USER_EMAIL=your-email@example.com
   JIRA_API_TOKEN=your-token
   JIRA_PROJECT_KEY=SUP
   JIRA_ASSIGNEE_NAME="John Peterson"

   # Gemini AI Configuration
   GEMINI_API_KEY=your-gemini-key
   ```

3. **Database Initialization**:
   ```bash
   bin/rails db:prepare
   bin/rails db:seed
   ```

4. **Running Background Workers**:
   ```bash
   bin/jobs
   ```

## Workflow
1. Tickets are created in the `SupportTicket` model via forms/emails (mocked via `db/seeds.rb`).
2. `NightlySupportTicketJob` runs (scheduled via `config/recurring.yml`).
3. For each ticket:
   - Data is masked (`DataMasker`).
   - Category is assigned (`Classifiers::Keyword` then `Classifiers::Ai`).
   - Sync to Jira occurs (`JiraSyncService`).

## Compliance & Privacy
> [!IMPORTANT]
> **ActiveRecord Encryption**: All sensitive fields (`raw_content`, `filtered_content`, `payload`) are encrypted at the database level using Rails' built-in encryption. This ensures data is secure at rest.
> 
> **PII Filtering**: All tickets are filtered for sensitive data before being sent to external APIs:
> - **Credit Cards**: Partial masking is used, showing only the first 4 (BIN) and last 4 digits (e.g., `4111********4444`).
> - **CVV/CVC**: Security codes are automatically detected and masked.
> - **PII**: Emails and SSNs are fully masked.
> - **Addresses**: Physical addresses are heuristic-detected and masked.

**AI Usage**: If an agreement with the AI provider (Google/OpenAI) regarding GDPR, PCI, or PII compliance is in place, raw data could be sent, but by default, only masked data is transmitted.

## Testing
Run the test suite:
```bash
bundle exec rspec
```
