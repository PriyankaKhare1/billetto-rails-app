# frozen_string_literal: true

require "clerk/authenticatable"

class ApplicationController < ActionController::Base
  include Clerk::Authenticatable

  helper_method :current_user_id, :logged_in?

  private

  def current_user_id
    session[:clerk_user_id]
  end

  def logged_in?
    current_user_id.present?
  end

  def require_authentication!
    unless logged_in?
      respond_to do |format|
        format.html { redirect_to sign_in_path, alert: "Please sign in to vote." }
        format.turbo_stream { render turbo_stream: turbo_stream.replace("flash", partial: "shared/flash", locals: { message: "Please sign in to vote." }) }
      end
    end
  end
end
