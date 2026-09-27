# frozen_string_literal: true

module Voting
  class Service
    def initialize(event_store: Rails.configuration.event_store)
      @event_store = event_store
    end

    def upvote(event:, user_id:)
      domain_event = Voting::EventUpvoted.new(data: {
        event_id: event.id,
        user_id:  user_id,
      })

      publish(domain_event)
      event.increment!(:upvotes_count)
    end

    def downvote(event:, user_id:)
      domain_event = Voting::EventDownvoted.new(data: {
        event_id: event.id,
        user_id:  user_id,
      })

      publish(domain_event)
      event.increment!(:downvotes_count)
    end

    private

    attr_reader :event_store

    def publish(domain_event)
      streams = domain_event.stream_names
      event_store.append(domain_event, stream_name: streams.first)

      streams.drop(1).each do |stream|
        event_store.link(domain_event.event_id, stream_name: stream)
      end
    end
  end
end
