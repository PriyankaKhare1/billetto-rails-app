# frozen_string_literal: true

Rails.configuration.to_prepare do
  Rails.configuration.clerk_publishable_key = ENV["CLERK_PUBLISHABLE_KEY"]
  Rails.configuration.clerk_secret_key      = ENV["CLERK_SECRET_KEY"]
end
