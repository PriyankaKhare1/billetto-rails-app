# frozen_string_literal: true

# Rake tasks for Billetto API data ingestion
# Doc 1: "Fetches and ingests events data from the Billetto API"
namespace :billetto do
  desc "Ingest events from Billetto API into local database"
  task ingest_events: :environment do
    puts "Starting Billetto events ingestion..."

    ingestor = BillettoEventIngestor.new
    result   = ingestor.ingest_all(pages: 5)

    puts "Ingestion complete!"
    puts "  Created: #{result.created}"
    puts "  Updated: #{result.updated}"
    puts "  Failed:  #{result.failed}"
  end

  desc "Test Billetto API connection"
  task test_connection: :environment do
    puts "Testing Billetto API connection..."

    service  = BillettoApiService.new
    response = service.fetch_events(page: 1, per_page: 3)

    puts "Connection successful!"
    puts "Response: #{response.inspect}"
  rescue BillettoApiService::AuthenticationError => e
    puts "Authentication failed: #{e.message}"
  rescue BillettoApiService::ApiError => e
    puts "API error: #{e.message}"
  end
end
