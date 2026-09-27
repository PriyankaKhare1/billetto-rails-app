# frozen_string_literal: true

class BillettoApiService
  include HTTParty

  BASE_URL = "https://api.billetto.co.uk/v3"
  DEFAULT_PAGE_SIZE = 20

  class ApiError < StandardError; end
  class AuthenticationError < ApiError; end
  class NotFoundError < ApiError; end

  def initialize(
    access_key_id: ENV["BILLETTO_ACCESS_KEY_ID"],
    secret_key: ENV["BILLETTO_SECRET_KEY"]
  )
    @access_key_id = access_key_id
    @secret_key    = secret_key
    @headers = {
      "X-Access-Key-Id"     => @access_key_id,
      "X-Secret-Access-Key" => @secret_key,
      "Content-Type"        => "application/json",
      "Accept"              => "application/json"
    }
  end

  def fetch_events(page: 1, per_page: DEFAULT_PAGE_SIZE)
    response = self.class.get(
      "#{BASE_URL}/events",
      headers: @headers,
      query: { page: page, per_page: per_page }
    )
    handle_response(response)
  end

  def fetch_event(event_id)
    response = self.class.get(
      "#{BASE_URL}/events/#{event_id}",
      headers: @headers
    )
    handle_response(response)
  end

  private

  def handle_response(response)
    case response.code
    when 200
      response.parsed_response
    when 401
      raise AuthenticationError, "Invalid API key"
    when 404
      raise NotFoundError, "Resource not found"
    when 429
      raise ApiError, "Rate limit exceeded"
    else
      raise ApiError, "API request failed with status #{response.code}: #{response.body}"
    end
  end
end
