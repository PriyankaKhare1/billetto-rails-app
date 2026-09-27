# frozen_string_literal: true

module Voting
  def self.subscriptions
    [].map(&:subscriptions).reduce({}) { |acc, s| acc.merge(s) }
  end
end
