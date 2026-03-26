require "service_helper"

RSpec.describe Tools::CreateEvent do
  let(:title)          { "Team Sync" }
  let(:start_time)     { "2026-04-01T10:00:00Z" }
  let(:end_time)       { "2026-04-01T10:30:00Z" }
  let(:attendee_email) { "john@example.com" }

  let(:calendar_service) { instance_double(Google::Apis::CalendarV3::CalendarService) }
  let(:created_event)    { double("created_event", id: "abc123eventid") }

  before do
    allow(Google::Apis::CalendarV3::CalendarService).to receive(:new).and_return(calendar_service)
    allow(calendar_service).to receive(:authorization=)
    allow(Google::Auth::ServiceAccountCredentials).to receive(:make_creds).and_return(double("credentials"))
    allow(File).to receive(:open).and_return(double("file"))
    stub_const("ENV", ENV.to_hash.merge(
      "GOOGLE_CREDENTIALS_PATH" => "/fake/path/credentials.json",
      "GOOGLE_CALENDAR_ID"      => "test-calendar@example.com"
    ))
  end

  context "when the API call succeeds" do
    before do
      allow(calendar_service).to receive(:insert_event).and_return(created_event)
    end

    it "returns the event ID string" do
      result = described_class.call(
        title:          title,
        start_time:     start_time,
        end_time:       end_time,
        attendee_email: attendee_email
      )

      expect(result).to eq("abc123eventid")
    end

    it "calls insert_event on the calendar service" do
      expect(calendar_service).to receive(:insert_event)

      described_class.call(
        title:          title,
        start_time:     start_time,
        end_time:       end_time,
        attendee_email: attendee_email
      )
    end
  end

  context "when a Google::Apis::Error is raised" do
    before do
      allow(calendar_service).to receive(:insert_event)
        .and_raise(Google::Apis::Error, "quota exceeded")
    end

    it "returns nil without raising" do
      result = described_class.call(
        title:          title,
        start_time:     start_time,
        end_time:       end_time,
        attendee_email: attendee_email
      )

      expect(result).to be_nil
    end
  end

  context "when an unexpected StandardError is raised" do
    before do
      allow(calendar_service).to receive(:insert_event)
        .and_raise(StandardError, "network timeout")
    end

    it "returns nil without raising" do
      result = described_class.call(
        title:          title,
        start_time:     start_time,
        end_time:       end_time,
        attendee_email: attendee_email
      )

      expect(result).to be_nil
    end
  end
end
