# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Clerk sign-in and event voting", type: :system do
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

  it "renders Clerk sign-in and sign-up UI containers" do
    visit sign_in_path
    expect(page).to have_content("Sign In")
    expect(page).to have_css("#clerk-sign-in")

    visit sign_up_path
    expect(page).to have_content("Sign Up")
    expect(page).to have_css("#clerk-sign-up")
  end

  it "registers a vote and shows the updated count on screen" do
    sign_in_as("test_user_system_123")
    visit events_path

    within("#vote_bar_#{event.id}") do
      find("button.vote-btn-up").click
    end

    expect(event.reload.upvotes_count).to eq(1)
  end

  it "shows an error when the signed-in user votes twice" do
    sign_in_as("test_user_system_123")
    visit events_path

    2.times do
      within("#vote_bar_#{event.id}") do
        find("button.vote-btn-up").click
      end
      visit events_path if page.has_content?("Upvoted!")
    end

    expect(page).to have_content("You have already voted on this event.")
    expect(event.reload.upvotes_count).to eq(1)
  end

  it "asks signed-out visitors to sign in before voting" do
    visit events_path

    expect(page).to have_link("Sign in to vote")
    expect(page).not_to have_css("button.vote-btn-up")
  end
end
