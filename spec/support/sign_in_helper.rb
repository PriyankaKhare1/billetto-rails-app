# frozen_string_literal: true

module SignInHelper
  def sign_in_as(user_id)
    visit test_sign_in_path(user_id: user_id)
  end
end

RSpec.configure do |config|
  config.include SignInHelper, type: :system
end
