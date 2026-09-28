# frozen_string_literal: true

# Only available in test environment - allows system tests to simulate sign-in
class TestSessionsController < ApplicationController
  def create
    raise "Not available in production" unless Rails.env.test?
    session[:clerk_user_id] = params[:user_id]
    redirect_to root_path
  end
end
