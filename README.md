<div align="center">
  <h1>🎫 Support Tickets Sort App</h1>
  <p><strong>Intelligent Support Ticket Processing & Classification</strong></p>

  [![Ruby Style Guide](https://img.shields.io/badge/code_style-rubocop-brightgreen.svg)](https://github.com/rubocop/rubocop)
  [![Ruby Critic](https://img.shields.io/badge/rubycritic-A-brightgreen)](https://github.com/whitesmith/rubycritic)
  [![Rails](https://img.shields.io/badge/Rails-7.2-CC0000.svg?logo=rubyonrails&logoColor=white)](https://rubyonrails.org)
</div>

<br />

## 🌟 Overview

The **Support Tickets Sort App** is a Ruby on Rails application designed to automate the ingestion, privacy protection, classification, and synchronization of support tickets. It ensures any sensitive Personal Identifiable Information (PII) is masked before utilizing intelligent categorization (via Keyword matching and Google Gemini AI) and automatically syncs categorized tickets into Jira.

---

## ✨ Key Features

- 🤖 **Automated Processing**: Leverages Solid Queue to run nightly background jobs, systematically processing all pending support tickets.
- 🔒 **Privacy First**: Built-in `DataMasker` service rigorously scrubs Credit Cards, CVVs, Emails, Physical Addresses, and SSNs before any data leaves your infrastructure. 
- 🧠 **Hybrid Classification**: Implements a fast keyword-matching strategy, gracefully falling back to advanced AI (Google Gemini) for nuanced tickets.
- 🔄 **Jira Integration**: Seamlessly interfaces with Jira to automatically create tasks with relevant project and assignee details.

---

## 🛠️ Setup & Installation

### 1. Prerequisites
Ensure your local development environment has the following installed:
- **Ruby**: `3.3.0` or higher
- **Rails**: `7.2` (or `8.0`)
- **Database**: `SQLite3`

### 2. Environment Configuration
Create a `.env` file in the root directory (based on `.env.example`).
```env
# Jira Configuration
JIRA_SITE="https://your-domain.atlassian.net"
JIRA_USER_EMAIL="your-email@example.com"
JIRA_API_TOKEN="your-token"
JIRA_PROJECT_KEY="SUP"
JIRA_ASSIGNEE_NAME="John Peterson"

# Gemini AI Configuration
GEMINI_API_KEY="your-gemini-key"
```

### 3. Database Initialization
Prepare the database and seed it with mock support tickets:
```bash
bin/rails db:prepare
bin/rails db:seed
```

### 4. Background Workers
The application relies on Solid Queue for processing tickets asynchronously. Run the workers locally with:
```bash
bin/jobs
```

---

## 🚀 Workflow

1. **Ingestion**: Tickets are created in the `SupportTicket` model via forms/emails (currently mocked via `db/seeds.rb`).
2. **Scheduling**: The `NightlySupportTicketJob` is dispatched automatically via the recurring jobs configuration (`config/recurring.yml`).
3. **Processing Pipeline**: For each pending ticket:
   - **Masking**: PII is scrubbed (`DataMasker`).
   - **Classification**: Categorized via `Classifiers::Keyword` or `Classifiers::Ai`.
   - **Synchronization**: Synced securely to Jira (`JiraSyncService`).

---

## 🛡️ Compliance & Privacy Measures

> [!IMPORTANT]
> **ActiveRecord Encryption**: All sensitive fields (`raw_content`, `filtered_content`, `payload`) are encrypted at the database level using Rails' built-in encryption, keeping data secure at rest.

**Data Filtering Specifications**:
All tickets are rigorously filtered for sensitive data before external API interactions:
- 💳 **Credit Cards**: Partial masking showing only BIN and last 4 digits (e.g., `4111********4444`).
- 🔢 **CVV/CVC**: Autodetected and fully masked.
- 👤 **PII**: Emails and SSNs are fully redacted.
- 🏠 **Addresses**: Physical addresses are detected via heuristics and masked.

*(Note: If a compliance agreement with the AI provider regarding GDPR/PCI is in place, raw data transmission could be configured, but by default, it is restricted to masked data.)*

---

## 🧪 Testing

To run the robust RSpec test suite covering classifiers, services, and jobs:

```bash
bundle exec rspec
```
