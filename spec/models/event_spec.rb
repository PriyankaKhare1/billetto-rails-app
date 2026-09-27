# frozen_string_literal: true

require "rails_helper"

RSpec.describe Event, type: :model do
  describe "validations" do
    subject(:event) do
      Event.new(
        billetto_id: "BLT-TEST-001",
        title: "Test Workshop",
        start_date: 1.week.from_now,
        upvotes_count: 0,
        downvotes_count: 0
      )
    end

    it "is valid with valid attributes" do
      expect(event).to be_valid
    end

    it "is invalid without a title" do
      event.title = nil
      expect(event).not_to be_valid
      expect(event.errors[:title]).to include("can't be blank")
    end

    it "is invalid with blank title" do
      event.title = ""
      expect(event).not_to be_valid
    end

    it "is invalid without a start_date" do
      event.start_date = nil
      expect(event).not_to be_valid
      expect(event.errors[:start_date]).to include("can't be blank")
    end

    it "is invalid without a billetto_id" do
      event.billetto_id = nil
      expect(event).not_to be_valid
    end

    it "is invalid with duplicate billetto_id" do
      event.save!
      duplicate = Event.new(
        billetto_id: "BLT-TEST-001",
        title: "Another Event",
        start_date: 1.week.from_now
      )
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:billetto_id]).to include("has already been taken")
    end

    it "is invalid with negative upvotes_count" do
      event.upvotes_count = -1
      expect(event).not_to be_valid
    end

    it "is invalid with negative downvotes_count" do
      event.downvotes_count = -1
      expect(event).not_to be_valid
    end
  end

  describe "scopes" do
    before do
      Event.create!(billetto_id: "BLT-PAST",   title: "Past Event",   start_date: 1.week.ago)
      Event.create!(billetto_id: "BLT-FUTURE", title: "Future Event", start_date: 1.week.from_now)
    end

    it "upcoming scope returns only future events" do
      expect(Event.upcoming.map(&:billetto_id)).to include("BLT-FUTURE")
      expect(Event.upcoming.map(&:billetto_id)).not_to include("BLT-PAST")
    end

    it "past scope returns only past events" do
      expect(Event.past.map(&:billetto_id)).to include("BLT-PAST")
      expect(Event.past.map(&:billetto_id)).not_to include("BLT-FUTURE")
    end
  end
end
