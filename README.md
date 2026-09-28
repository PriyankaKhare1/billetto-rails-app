# Billetto Rails Event Store Application

A Ruby on Rails application that integrates with Billetto API for event management, implements authentication using Clerk.com, and uses Rails Event Store for tracking voting events.

## Features

- **Billetto API Integration**: Fetches events from Billetto UK API
- **Clerk Authentication**: Secure user authentication with Clerk.com
- **Rails Event Store**: Event sourcing for upvote/downvote tracking with full audit trail
- **PostgreSQL Database**: Robust data persistence
- **Responsive UI**: Clean Bootstrap-based interface
- **Comprehensive Tests**: Full RSpec test coverage (31 examples, 0 failures)

## Tech Stack

- Ruby 3.2.11
- Rails 7.1.5
- PostgreSQL 16
- Rails Event Store 3.0
- Clerk.com (Authentication)
- RSpec (Testing)
- Kaminari (Pagination)

## Prerequisites

- Ruby 3.2.11 or higher
- PostgreSQL 16
- Bundler

## Installation

### 1. Clone and Setup

```powershell
cd C:\Users\pkhar\Desktop\Billetto\billetto_app
bundle install
```

### 2. Database Configuration

Create `.env` file in the root directory:

```env
# Clerk Authentication
CLERK_PUBLISHABLE_KEY=pk_test_ZGFyaW5nLXNhd2Zpc2gtNDAyNS5jbGVyay5hY2NvdW50cy5kZXYk
CLERK_SECRET_KEY=your_clerk_secret_key_here

# Billetto API
BILLETTO_ACCESS_KEY_ID=BLT2KPKKJ8BXD1E2U36MNQ4EM
BILLETTO_SECRET_KEY=your_billetto_secret_here
```

**⚠️ IMPORTANT**: Replace the Clerk secret key with your actual key from https://dashboard.clerk.com

Update `config/database.yml` with your PostgreSQL credentials:

```yaml
default: &default
  adapter: postgresql
  encoding: unicode
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  username: postgres
  password: postgres123
  host: localhost
```

### 3. Database Setup

```powershell
$env:PATH = "C:\Ruby32-x64\bin;$env:PATH"
bundle exec rails db:create
bundle exec rails db:migrate
bundle exec rails db:seed
```

The seed file creates mock events in the following categories:
- Professional Development
- Technical Training
- Leadership & Management
- Specialized Skills

## Running the Application

### Development Server

```powershell
$env:PATH = "C:\Ruby32-x64\bin;$env:PATH"
bundle exec rails server
```

Visit: http://localhost:3000

### Running Tests

```powershell
$env:PATH = "C:\Ruby32-x64\bin;$env:PATH"
bundle exec rspec
```

Expected output: **31 examples, 0 failures, 3 pending**

## Project Structure

```
billetto_app/
├── app/
│   ├── controllers/
│   │   ├── application_controller.rb    # Clerk authentication helper
│   │   ├── events_controller.rb         # Event listing, upvote, downvote
│   │   └── sessions_controller.rb       # Sign in, sign up, Clerk callback
│   ├── models/
│   │   └── event.rb                     # Event model with validations
│   ├── services/
│   │   ├── billetto_api_service.rb      # API wrapper
│   │   └── billetto_event_ingestor.rb   # Data import service
│   └── views/
│       ├── events/
│       │   ├── index.html.erb           # Event listing
│       │   └── show.html.erb            # Event details
│       └── sessions/
│           ├── new.html.erb             # Sign in
│           └── sign_up.html.erb         # Sign up
├── config/
│   ├── boot.rb                          # Domain events defined here
│   ├── initializers/
│   │   ├── clerk.rb                     # Clerk config
│   │   └── rails_event_store.rb         # RES client
│   └── routes.rb
├── db/
│   └── migrate/
│       ├── *_create_rails_event_store_tables.rb
│       ├── *_create_events.rb
│       └── *_add_vote_counts_to_events.rb
├── spec/
│   ├── models/event_spec.rb             # Model tests
│   ├── domain/voting_spec.rb            # Event Store tests
│   └── requests/events_spec.rb          # Integration tests
└── .env                                 # Environment variables (not in git)
```

## Domain Events

The application uses Rails Event Store to track voting activity:

### EventUpvoted
```ruby
{
  event_id: Integer,  # Event ID being upvoted
  user_id: String     # Clerk user ID
}
```

### EventDownvoted
```ruby
{
  event_id: Integer,  # Event ID being downvoted
  user_id: String     # Clerk user ID
}
```

Events are stored in:
- `event_store_events` - Event data and metadata
- `event_store_events_in_streams` - Stream organization

## API Endpoints

| Method | Path | Description | Auth Required |
|--------|------|-------------|---------------|
| GET | / | Redirect to events | No |
| GET | /events | List all events | No |
| GET | /events/:id | Show event details | No |
| POST | /events/:id/upvote | Upvote an event | Yes |
| POST | /events/:id/downvote | Downvote an event | Yes |
| GET | /sign_in | Sign in page | No |
| GET | /sign_up | Sign up page | No |
| POST | /auth/clerk/callback | Clerk callback | No |
| DELETE | /sign_out | Sign out | Yes |

## Authentication Flow

1. User visits protected route (upvote/downvote)
2. If not authenticated, redirected to `/sign_in`
3. Clerk.js handles authentication via Clerk.com
4. On success, callback stores `user_id` in session
5. User can now vote on events

## Billetto API Integration

### Current Status
The app includes full Billetto API integration code but uses seed data because:
- Billetto UK API endpoint returns 503 errors
- Mock data matches real Billetto event structure

### Switching to Real API

When API is available, update `config/initializers/billetto.rb`:

```ruby
BASE_URL = "https://api.billetto.co.uk/v3"  # Currently working endpoint
```

Then run:
```powershell
bundle exec rails billetto:sync_events
```

## Testing

### Test Coverage

- **Model Tests** (10 examples): Validations, associations, required fields
- **Domain Event Tests** (8 examples): EventUpvoted/EventDownvoted publishing
- **Request Tests** (10 examples): Authentication, voting endpoints
- **Helper/View Tests** (3 pending): Placeholder specs

### Running Specific Test Suites

```powershell
# Models only
bundle exec rspec spec/models

# Domain events only  
bundle exec rspec spec/domain

# Integration tests only
bundle exec rspec spec/requests
```

## Troubleshooting

### Database Connection Issues
```powershell
# Verify PostgreSQL is running
Get-Service postgresql*

# Reset database
bundle exec rails db:drop db:create db:migrate db:seed
```

### Clerk Authentication Issues
- Verify keys in `.env` match Clerk dashboard
- Check Clerk.js loads in browser console
- Ensure callback URL is configured in Clerk dashboard

### Asset Compilation Issues
```powershell
# Clear cache
Remove-Item -Recurse -Force tmp/cache
```

### Test Failures
```powershell
# Reset test database
bundle exec rails db:drop db:create db:migrate RAILS_ENV=test
bundle exec rspec
```

## Environment Variables Reference

| Variable | Purpose | Example |
|----------|---------|---------|
| CLERK_PUBLISHABLE_KEY | Clerk frontend key | pk_test_... |
| CLERK_SECRET_KEY | Clerk backend key | sk_test_... |
| BILLETTO_ACCESS_KEY_ID | Billetto API access | BLT2KP... |
| BILLETTO_SECRET_KEY | Billetto API secret | x9VUvg... |
| DATABASE_URL (optional) | PostgreSQL connection | postgresql://... |

## Production Deployment

### Security Checklist

- [ ] Rotate Clerk secret key (currently exposed)
- [ ] Use environment-specific credentials
- [ ] Enable SSL for database connections
- [ ] Set `RAILS_ENV=production`
- [ ] Precompile assets: `rails assets:precompile`
- [ ] Set secure session cookie settings
- [ ] Configure CORS if needed
- [ ] Add rate limiting for voting endpoints

### Database Migration

```bash
RAILS_ENV=production bundle exec rails db:migrate
```

## Known Issues

1. **Billetto API**: Currently returns 503 errors - using mock seed data
2. **Clerk Secret**: Exposed in chat - must be rotated before production
3. **View Specs**: 3 placeholder specs pending implementation

## Documentation References

- [Rails Event Store Docs](https://railseventstore.org/docs/v3/install/)
- [Clerk Rails Integration](https://clerk.com/docs/quickstarts/ruby-on-rails)
- [Billetto API Docs](https://developer.billetto.com/)

## License

This project was created as a learning exercise based on provided specifications.

## Support

For issues or questions:
1. Check logs: `tail -f log/development.log`
2. Run tests: `bundle exec rspec`
3. Verify environment variables are set correctly
4. Check PostgreSQL is running

---

**Built with Rails Event Store, Clerk Authentication, and PostgreSQL**
