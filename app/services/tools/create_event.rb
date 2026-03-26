require "google/apis/calendar_v3"
require "googleauth"

module Tools
  class CreateEvent
    CALENDAR_SCOPE = Google::Apis::CalendarV3::AUTH_CALENDAR

    def self.call(title:, start_time:, end_time:, attendee_email:)
      new.call(title: title, start_time: start_time, end_time: end_time, attendee_email: attendee_email)
    end

    def call(title:, start_time:, end_time:, attendee_email:)
      service = build_service
      calendar_id = ENV["GOOGLE_CALENDAR_ID"] || "primary"

      event = Google::Apis::CalendarV3::Event.new(
        summary: title,
        start: Google::Apis::CalendarV3::EventDateTime.new(
          date_time: start_time,
          time_zone: "UTC"
        ),
        end: Google::Apis::CalendarV3::EventDateTime.new(
          date_time: end_time,
          time_zone: "UTC"
        ),
        attendees: [
          Google::Apis::CalendarV3::EventAttendee.new(email: attendee_email)
        ]
      )

      result = service.insert_event(calendar_id, event)
      result.id
    rescue Google::Apis::Error => e
      Rails.logger.error("[Tools::CreateEvent] Google API error: #{e.message}")
      nil
    rescue StandardError => e
      Rails.logger.error("[Tools::CreateEvent] Unexpected error: #{e.message}")
      nil
    end

    private

    def build_service
      credentials_path = ENV["GOOGLE_CREDENTIALS_PATH"]

      authorizer = Google::Auth::ServiceAccountCredentials.make_creds(
        json_key_io: File.open(credentials_path),
        scope: CALENDAR_SCOPE
      )

      service = Google::Apis::CalendarV3::CalendarService.new
      service.authorization = authorizer
      service
    end
  end
end
