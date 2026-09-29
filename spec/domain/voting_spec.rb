# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Voting with Rails Event Store", type: :request do
  let(:event_store) { Rails.configuration.event_store }

  let!(:billetto_event) do
    Event.create!(
      billetto_id: "BLT-VOTE-001",
      title: "Voting Test Workshop",
      start_date: 1.week.from_now,
      upvotes_count: 0,
      downvotes_count: 0
    )
  end

  before do
    allow_any_instance_of(ApplicationController)
      .to receive(:current_user_id).and_return("clerk_user_test_123")
    allow_any_instance_of(ApplicationController)
      .to receive(:logged_in?).and_return(true)
  end

  describe "EventUpvoted domain event" do
    it "is published to Rails Event Store when upvoting" do
      expect {
        post upvote_event_path(billetto_event)
      }.to change {
        event_store.read.stream("Event$#{billetto_event.id}").to_a.count
      }.by(1)
    end

    it "publishes EventUpvoted with correct data" do
      post upvote_event_path(billetto_event)

      published_event = event_store
        .read
        .stream("Event$#{billetto_event.id}")
        .last

      expect(published_event).to be_a(Voting::EventUpvoted)
      expect(published_event.data[:event_id]).to eq(billetto_event.id)
      expect(published_event.data[:user_id]).to eq("clerk_user_test_123")
    end

    it "stores user_id for traceability" do
      post upvote_event_path(billetto_event)

      event = event_store.read.stream("Event$#{billetto_event.id}").last
      expect(event.data[:user_id]).to be_present
    end
  end

  describe "EventDownvoted domain event" do
    it "is published to Rails Event Store when downvoting" do
      expect {
        post downvote_event_path(billetto_event)
      }.to change {
        event_store.read.stream("Event$#{billetto_event.id}").to_a.count
      }.by(1)
    end

    it "publishes EventDownvoted with correct data" do
      post downvote_event_path(billetto_event)

      published_event = event_store
        .read
        .stream("Event$#{billetto_event.id}")
        .last

      expect(published_event).to be_a(Voting::EventDownvoted)
      expect(published_event.data[:event_id]).to eq(billetto_event.id)
    end
  end

  describe "vote counts" do
    it "increments upvotes_count after upvote" do
      expect {
        post upvote_event_path(billetto_event)
      }.to change { billetto_event.reload.upvotes_count }.from(0).to(1)
    end

    it "increments downvotes_count after downvote" do
      expect {
        post downvote_event_path(billetto_event)
      }.to change { billetto_event.reload.downvotes_count }.from(0).to(1)
    end

    it "tracks multiple votes correctly" do
      post upvote_event_path(billetto_event)
      post downvote_event_path(billetto_event)

      billetto_event.reload
      expect(billetto_event.upvotes_count).to eq(1)
      expect(billetto_event.downvotes_count).to eq(0)
    end
  end
end
