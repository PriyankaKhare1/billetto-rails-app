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
    token = cookies[:__session] || cookies[:__client_uat]
    return nil if token.blank?

    begin
      payload = token.split('.')[1]
      return nil if payload.blank?

      decoded = Base64.decode64(payload + '==')
      data = JSON.parse(decoded)
      data['sub']
    rescue => e
      Rails.logger.warn "Clerk token decode failed: #{e.message}"
      nil
    end
  end
end
