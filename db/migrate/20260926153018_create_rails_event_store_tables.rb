# frozen_string_literal: true

# Rails Event Store 3.0+ migration
# Ref: https://railseventstore.org/docs/v3/install/
class CreateRailsEventStoreTables < ActiveRecord::Migration[7.1]
  def change
    create_table(:event_store_events, force: false) do |t|
      t.string      :event_id,   null: false, index: { unique: true }
      t.string      :event_type, null: false, index: true
      t.binary      :metadata
      t.binary      :data,       null: false
      t.datetime    :created_at, null: false, index: true
      t.datetime    :valid_at,   index: true
    end

    create_table(:event_store_events_in_streams, force: false) do |t|
      t.string      :stream,     null: false
      t.integer     :position,   null: true
      t.string      :event_id,   null: false, index: false
      t.datetime    :created_at, null: false, index: true

      t.index [:stream, :position], unique: true
      t.index [:stream, :event_id], unique: true
    end
    
    add_foreign_key :event_store_events_in_streams, :event_store_events,
                    column: :event_id, primary_key: :event_id
  end
end
