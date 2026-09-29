# frozen_string_literal: true

class SessionsController < ApplicationController
  def new
    redirect_to root_path if logged_in?
  end

  def sign_up
    redirect_to root_path if logged_in?
  end

  def create
    clerk_user_id = verified_clerk_user_id

    if clerk_user_id.present?
      reset_session
      session[:clerk_user_id] = clerk_user_id
      respond_to do |format|
        format.json { render json: { status: "ok", user_id: clerk_user_id } }
        format.html { redirect_to root_path, notice: "Successfully signed in!" }
      end
    else
      respond_to do |format|
        format.json { render json: { status: "error" }, status: :unauthorized }
        format.html { redirect_to sign_in_path, alert: "Authentication failed." }
      end
    end
  end

  def destroy
    session.delete(:clerk_user_id)
    redirect_to root_path, notice: "Successfully signed out!"
  end

  private

  def verified_clerk_user_id
    clerk_verified_session_claims&.fetch("sub", nil)
  end
end
