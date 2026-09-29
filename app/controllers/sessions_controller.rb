# frozen_string_literal: true

class SessionsController < ApplicationController
  def new
    redirect_to root_path if logged_in?
  end

  def sign_up
    redirect_to root_path if logged_in?
  end

  def create
    clerk_user_id = params[:clerk_user_id] || extract_clerk_user_from_token

    if clerk_user_id.present?
      session[:clerk_user_id] = clerk_user_id
      redirect_to root_path, notice: "Successfully signed in!"
    else
      session[:clerk_pending] = true
      redirect_to root_path, notice: "Welcome! You are now signed in."
    end
  end

  def destroy
    session.delete(:clerk_user_id)
    session.delete(:clerk_pending)
    redirect_to root_path, notice: "Successfully signed out!"
  end

  private

  def extract_clerk_user_from_token
    token = cookies[:__session]
    return nil if token.blank?

    begin
      jwks_response = Net::HTTP.get(URI("https://#{clerk_frontend_api}/v1/jwks"))
      jwks = JSON.parse(jwks_response)
      jwk = JWT::JWK::Set.new(jwks)
      payload, = JWT.decode(token, nil, true, algorithms: ["RS256"], jwks: jwk)
      payload["sub"]
    rescue => e
      Rails.logger.warn "Clerk token verification failed: #{e.message}"
      nil
    end
  end

  def clerk_frontend_api
    key = ENV["CLERK_PUBLISHABLE_KEY"].to_s
    encoded = key.sub("pk_test_", "").sub("pk_live_", "")
    Base64.decode64(encoded + "==").strip.chomp("$")
  end
end
