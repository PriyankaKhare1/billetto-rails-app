# frozen_string_literal: true

class BillettoEventIngestor
  Result = Struct.new(:created, :updated, :failed, keyword_init: true)

  def initialize(api_service = BillettoApiService.new)
    @api_service = api_service
  end

  def ingest_all(pages: 5)
    result = Result.new(created: 0, updated: 0, failed: 0)

    pages.times do |i|
      response = @api_service.fetch_events(page: i + 1)
      events_data = extract_events(response)

      break if events_data.empty?

      events_data.each { |event_data| ingest_single(event_data, result) }
    end

    result
  rescue BillettoApiService::ApiError => e
    Rails.logger.error("Billetto API error: #{e.message}")
    raise
  end

  private

  def extract_events(response)
    return [] unless response.is_a?(Hash)
    response["data"] || response["events"] || []
  end

  def ingest_single(event_data, result)
    event = Event.find_or_initialize_by(billetto_id: event_data["id"].to_s)

    event.assign_attributes(
      title:       event_data["title"],
      description: event_data["description"],
      start_date:  parse_date(event_data["start_date"] || event_data["starts_at"]),
      end_date:    parse_date(event_data["end_date"] || event_data["ends_at"]),
      image_url:   extract_image(event_data),
      location:    extract_location(event_data),
      url:         event_data["url"] || event_data["slug"]
    )

    if event.new_record?
      event.save! ? result.created += 1 : result.failed += 1
    else
      event.save! ? result.updated += 1 : result.failed += 1
    end
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.warn("Failed to ingest event #{event_data['id']}: #{e.message}")
    result.failed += 1
  end

  def parse_date(date_string)
    return nil if date_string.blank?
    Time.zone.parse(date_string)
  rescue ArgumentError
    nil
  end

  def extract_image(event_data)
    event_data.dig("image", "url") || event_data["image_url"] || event_data["cover_image"]
  end

  def extract_location(event_data)
    venue = event_data["venue"] || event_data["location"]
    return venue if venue.is_a?(String)
    return unless venue.is_a?(Hash)

    [venue["name"], venue["city"], venue["country"]].compact.join(", ")
  end
end
