# frozen_string_literal: true

# Database migration to create the Support Tickets table.
class CreateSupportTickets < ActiveRecord::Migration[7.2]
  def change
    create_table :support_tickets do |t|
      t.integer :customer_type
      t.text :raw_content
      t.text :filtered_content
      t.string :category
      t.string :jira_ticket_key
      t.string :status
      t.string :fingerprint
      t.json :payload
      t.index :fingerprint, unique: true

      t.timestamps
    end
  end
end
