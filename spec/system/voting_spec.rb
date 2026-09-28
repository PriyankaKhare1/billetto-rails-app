# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Voting", type: :system do
  let!(:event) do
    Event.create!(
      billetto_id: "BLT-SYS-001",
      title: "System Test Workshop",
      start_date: 1.week.from_now,
      upvotes_count: 0,
      downvotes_count: 0
    )
  end

  before do
    driven_by :headless_chrome
  end

  context "when user is signed in via Clerk" do
    before do
      sign_in_as("test_user_system_123")
    end

    it "shows vote buttons on the events page" do
      visit events_path
      expect(page).to have_button("👍 0")
      expect(page).to have_button("👎 0")
    end

    it "increments upvote count when upvote button is clicked" do
      visit events_path
      click_button "👍 0"
      expect(page).to have_button("👍 1")
    end

    it "increments downvote count when downvote button is clicked" do
      visit events_path
      click_button "👎 0"
      expect(page).to have_button("👎 1")
    end
  end

  context "when user is not signed in" do
    it "shows sign in link instead of vote buttons" do
      visit events_path
      expect(page).to have_link("Sign in to vote")
      expect(page).not_to have_button("👍 0")
    end

    it "redirects to sign in page when visiting sign_in path" do
      visit sign_in_path
      expect(page).to have_content("Sign In")
    end

    it "redirects to sign up page when visiting sign_up path" do
      visit sign_up_path
      expect(page).to have_content("Sign Up")
    end
  end
end
