# frozen_string_literal: true

# Seed data for development - mimics real Billetto API response structure
# Real API: https://api.billetto.com/reference/list-public-events
# Event type: Class, Training & Workshop (GBP)

puts "Seeding events from mock Billetto data..."

events_data = [
  {
    billetto_id: "BLT-001",
    title: "Python for Beginners - Full Day Workshop",
    description: "A hands-on full day workshop covering Python fundamentals. Learn variables, loops, functions, and build your first project. No prior experience needed. Laptops provided.",
    start_date: 2.weeks.from_now,
    end_date: 2.weeks.from_now + 8.hours,
    image_url: "https://images.unsplash.com/photo-1526379095098-d400fd0bf935?w=800",
    location: "Tech Hub, Shoreditch, London",
    url: "https://billetto.co.uk/e/python-beginners-workshop"
  },
  {
    billetto_id: "BLT-002",
    title: "Digital Marketing Masterclass",
    description: "Learn the latest digital marketing strategies including SEO, social media marketing, email campaigns and paid advertising. Includes hands-on exercises and real case studies.",
    start_date: 3.weeks.from_now,
    end_date: 3.weeks.from_now + 6.hours,
    image_url: "https://images.unsplash.com/photo-1432888622747-4eb9a8efeb07?w=800",
    location: "Business Centre, Canary Wharf, London",
    url: "https://billetto.co.uk/e/digital-marketing-masterclass"
  },
  {
    billetto_id: "BLT-003",
    title: "Yoga Teacher Training - Weekend Intensive",
    description: "200-hour yoga teacher training weekend intensive. Covers asana, pranayama, meditation, anatomy and teaching methodology. Certification upon completion.",
    start_date: 1.week.from_now,
    end_date: 1.week.from_now + 16.hours,
    image_url: "https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=800",
    location: "Triyoga Centre, Camden, London",
    url: "https://billetto.co.uk/e/yoga-teacher-training"
  },
  {
    billetto_id: "BLT-004",
    title: "Watercolour Painting Class for Adults",
    description: "Discover the joy of watercolour painting in this relaxed and friendly class. All materials provided. Suitable for complete beginners and those looking to improve their technique.",
    start_date: 5.days.from_now,
    end_date: 5.days.from_now + 3.hours,
    image_url: "https://images.unsplash.com/photo-1513364776144-60967b0f800f?w=800",
    location: "The Art Room, Notting Hill, London",
    url: "https://billetto.co.uk/e/watercolour-painting-class"
  },
  {
    billetto_id: "BLT-005",
    title: "Public Speaking & Confidence Training",
    description: "Overcome your fear of public speaking with this practical training workshop. Learn proven techniques to communicate with clarity, confidence and impact in any situation.",
    start_date: 10.days.from_now,
    end_date: 10.days.from_now + 5.hours,
    image_url: "https://images.unsplash.com/photo-1475721027785-f74eccf877e2?w=800",
    location: "Toastmasters International, City of London",
    url: "https://billetto.co.uk/e/public-speaking-training"
  },
  {
    billetto_id: "BLT-006",
    title: "Introduction to Machine Learning",
    description: "A beginner-friendly introduction to machine learning concepts. Covers supervised and unsupervised learning, neural networks, and practical applications using Python and scikit-learn.",
    start_date: 4.days.from_now,
    end_date: 4.days.from_now + 7.hours,
    image_url: "https://images.unsplash.com/photo-1555949963-aa79dcee981c?w=800",
    location: "Google Campus, Shoreditch, London",
    url: "https://billetto.co.uk/e/intro-machine-learning"
  }
]

# Clear existing seed data first
Event.where(billetto_id: events_data.map { |e| e[:billetto_id] }).destroy_all

events_data.each do |data|
  event = Event.find_or_initialize_by(billetto_id: data[:billetto_id])
  event.assign_attributes(data)
  if event.save
    puts "  ✓ #{event.title}"
  else
    puts "  ✗ Failed: #{event.errors.full_messages.join(', ')}"
  end
end

puts "\nDone! #{Event.count} events in database."
