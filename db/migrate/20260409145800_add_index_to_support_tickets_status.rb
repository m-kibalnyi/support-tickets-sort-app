# frozen_string_literal: true

# Adds an index on status for efficient nightly job queries.
class AddIndexToSupportTicketsStatus < ActiveRecord::Migration[7.2]
  def change
    add_index :support_tickets, :status
  end
end
