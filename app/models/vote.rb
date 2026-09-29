class Vote < ApplicationRecord
  belongs_to :event
  validates :user_id,   presence: true
  validates :event_id,  presence: true
  validates :vote_type, presence: true, inclusion: { in: %w[up down] }
  validates :user_id, uniqueness: { scope: :event_id }
end
