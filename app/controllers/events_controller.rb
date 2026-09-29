# frozen_string_literal: true

class EventsController < ApplicationController
  before_action :set_event, only: [:show, :upvote, :downvote]
  before_action :require_authentication!, only: [:upvote, :downvote]

  def index
    @events = Event.order(start_date: :asc).page(params[:page]).per(12)
  end

  def show
  end

  def upvote
    begin
      voting_service.upvote(event: @event, user_id: current_user_id)
      respond_to do |format|
        format.html { redirect_to @event, notice: "Upvoted!" }
        format.turbo_stream
      end
    rescue Voting::Service::DuplicateVoteError
      respond_to do |format|
        format.html { redirect_to @event, alert: "You have already voted on this event." }
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "flash",
            partial: "shared/flash",
            locals: { message: "You have already voted on this event." }
          ), status: :unprocessable_entity
        end
      end
    end
  end

  def downvote
    begin
      voting_service.downvote(event: @event, user_id: current_user_id)
      respond_to do |format|
        format.html { redirect_to @event, notice: "Downvoted!" }
        format.turbo_stream
      end
    rescue Voting::Service::DuplicateVoteError
      respond_to do |format|
        format.html { redirect_to @event, alert: "You have already voted on this event." }
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "flash",
            partial: "shared/flash",
            locals: { message: "You have already voted on this event." }
          ), status: :unprocessable_entity
        end
      end
    end
  end

  private

  def set_event
    @event = Event.find(params[:id])
  end

  def voting_service
    @voting_service ||= Voting::Service.new
  end
end
