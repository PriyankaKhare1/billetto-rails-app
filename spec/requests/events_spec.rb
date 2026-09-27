# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Events", type: :request do
  let!(:event) do
    Event.create!(
      billetto_id: "BLT-REQ-001",
      title: "Test Workshop",
      start_date: 1.week.from_now,
      upvotes_count: 0,
      downvotes_count: 0
    )
  end

  describe "GET /events" do
    it "returns http success" do
      get events_path
      expect(response).to have_http_status(:success)
    end

    it "displays events listing" do
      get events_path
      expect(response.body).to include("Test Workshop")
    end
  end

  describe "GET /events/:id" do
    it "returns http success" do
      get event_path(event)
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /events/:id/upvote" do
    context "when user is NOT authenticated" do
      it "redirects to sign in page" do
        post upvote_event_path(event)
        expect(response).to redirect_to(sign_in_path)
      end

      it "does not increment upvotes_count" do
        expect {
          post upvote_event_path(event)
        }.not_to change { event.reload.upvotes_count }
      end
    end

    context "when user IS authenticated" do
      before do
        allow_any_instance_of(ApplicationController)
          .to receive(:current_user_id).and_return("clerk_user_123")
        allow_any_instance_of(ApplicationController)
          .to receive(:logged_in?).and_return(true)
      end

      it "increments upvotes_count" do
        expect {
          post upvote_event_path(event)
        }.to change { event.reload.upvotes_count }.by(1)
      end

      it "redirects back to event" do
        post upvote_event_path(event)
        expect(response).to redirect_to(event_path(event))
      end
    end
  end

  describe "POST /events/:id/downvote" do
    context "when user is NOT authenticated" do
      it "redirects to sign in page" do
        post downvote_event_path(event)
        expect(response).to redirect_to(sign_in_path)
      end

      it "does not increment downvotes_count" do
        expect {
          post downvote_event_path(event)
        }.not_to change { event.reload.downvotes_count }
      end
    end

    context "when user IS authenticated" do
      before do
        allow_any_instance_of(ApplicationController)
          .to receive(:current_user_id).and_return("clerk_user_123")
        allow_any_instance_of(ApplicationController)
          .to receive(:logged_in?).and_return(true)
      end

      it "increments downvotes_count" do
        expect {
          post downvote_event_path(event)
        }.to change { event.reload.downvotes_count }.by(1)
      end
    end
  end
end
