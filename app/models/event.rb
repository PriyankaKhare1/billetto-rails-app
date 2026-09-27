# frozen_string_literal: true

class Event < ApplicationRecord
  validates :title,       presence: true
  validates :billetto_id, presence: true, uniqueness: true
  validates :start_date,  presence: true
  validates :upvotes_count,   numericality: { greater_than_or_equal_to: 0 }
  validates :downvotes_count, numericality: { greater_than_or_equal_to: 0 }

  scope :upcoming, -> { where("start_date >= ?", Time.current).order(:start_date) }
  scope :past,     -> { where("start_date < ?",  Time.current).order(start_date: :desc) }
end
