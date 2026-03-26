require "google/apis/calendar_v3"
require "googleauth"

module Tools
  class CheckAvailability
    SLOT_DURATION_MINUTES = 30
    SCOPES = [Google::Apis::CalendarV3::AUTH_CALENDAR_READONLY].freeze

    # Public entry point.
    # Returns an array of free 30-minute slot hashes: [{ start: <Time>, end: <Time> }, ...]
    def self.call(date_range_start:, date_range_end:)
      new(date_range_start: date_range_start, date_range_end: date_range_end).call
    end

    def initialize(date_range_start:, date_range_end:)
      @range_start = Time.parse(date_range_start)
      @range_end   = Time.parse(date_range_end)
    end

    def call
      busy_intervals = fetch_busy_intervals
      free_slots(busy_intervals)
    rescue StandardError => e
      Rails.logger.error("[Tools::CheckAvailability] API error: #{e.class}: #{e.message}")
      []
    end

    private

    def fetch_busy_intervals
      service = Google::Apis::CalendarV3::CalendarService.new
      service.authorization = credentials

      calendar_id = ENV.fetch("GOOGLE_CALENDAR_ID", "primary")

      events = service.list_events(
        calendar_id,
        single_events: true,
        order_by: "startTime",
        time_min: @range_start.iso8601,
        time_max: @range_end.iso8601
      )

      (events.items || []).filter_map do |event|
        event_start = event.start&.date_time || (event.start&.date && Time.parse(event.start.date))
        event_end   = event.end&.date_time   || (event.end&.date   && Time.parse(event.end.date))
        next unless event_start && event_end

        { start: event_start, end: event_end }
      end
    end

    def free_slots(busy_intervals)
      slots = []
      slot_start = @range_start

      while slot_start + (SLOT_DURATION_MINUTES * 60) <= @range_end
        slot_end = slot_start + (SLOT_DURATION_MINUTES * 60)

        overlaps = busy_intervals.any? do |busy|
          slot_start < busy[:end] && slot_end > busy[:start]
        end

        slots << { start: slot_start, end: slot_end } unless overlaps

        slot_start = slot_end
      end

      slots
    end

    def credentials
      key_path = ENV["GOOGLE_CREDENTIALS_PATH"]
      raise "GOOGLE_CREDENTIALS_PATH is not set" if key_path.nil? || key_path.empty?

      File.open(key_path) do |f|
        Google::Auth::ServiceAccountCredentials.make_creds(
          json_key_io: f,
          scope: SCOPES
        )
      end
    end
  end
end
