# frozen_string_literal: true

Rails.configuration.to_prepare do
  Rails.configuration.clerk_publishable_key = ENV["CLERK_PUBLISHABLE_KEY"]
  Rails.configuration.clerk_secret_key      = ENV["CLERK_SECRET_KEY"]
end

Clerk.configure do |config|
  config.api_key = ENV["CLERK_SECRET_KEY"]
  config.excluded_routes = [
    "/",
    "/events",
    "/events/*",
    "/sign_in",
    "/sign_in/*",
    "/sign_up",
    "/sign_up/*",
    "/assets/*",
    "/favicon.ico",
    "/sign_out",
    "/up"
  ]
  config.excluded_routes << "/test/sign_in" if Rails.env.test?
end
