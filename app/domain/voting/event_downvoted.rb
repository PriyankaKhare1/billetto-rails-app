# frozen_string_literal: true

module Voting
  class EventDownvoted < RubyEventStore::Event
    SCHEMA = {
      event_id: Integer,
      user_id:  String,
    }.freeze

    def stream_names
      ["Event$#{data.fetch(:event_id)}"]
    end
  end
end
