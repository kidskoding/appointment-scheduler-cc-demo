require "service_helper"

RSpec.describe Tools::CheckAvailability do
  let(:range_start) { "2026-04-01 09:00:00 UTC" }
  let(:range_end)   { "2026-04-01 11:00:00 UTC" }

  let(:calendar_service) { instance_double(Google::Apis::CalendarV3::CalendarService) }

  before do
    allow(Google::Apis::CalendarV3::CalendarService).to receive(:new).and_return(calendar_service)
    allow(calendar_service).to receive(:authorization=)
    allow(Google::Auth::ServiceAccountCredentials).to receive(:make_creds).and_return(double("credentials"))
    allow(File).to receive(:open).and_yield(double("file"))
    stub_const("ENV", ENV.to_hash.merge(
      "GOOGLE_CREDENTIALS_PATH" => "/fake/path/credentials.json",
      "GOOGLE_CALENDAR_ID"      => "test-calendar@example.com"
    ))
  end

  context "when there are no busy intervals" do
    before do
      events_list = double("events_list", items: [])
      allow(calendar_service).to receive(:list_events).and_return(events_list)
    end

    it "returns an array of free 30-minute slots covering the full range" do
      result = described_class.call(date_range_start: range_start, date_range_end: range_end)

      expect(result).to be_an(Array)
      expect(result.length).to eq(4) # 09:00, 09:30, 10:00, 10:30
      expect(result.first).to include(:start, :end)
    end

    it "returns slots with the correct 30-minute duration" do
      result = described_class.call(date_range_start: range_start, date_range_end: range_end)

      result.each do |slot|
        expect(slot[:end] - slot[:start]).to eq(30 * 60)
      end
    end
  end

  context "when there is a busy interval covering one slot" do
    let(:busy_start) { Time.parse("2026-04-01 09:00:00 UTC") }
    let(:busy_end)   { Time.parse("2026-04-01 09:30:00 UTC") }

    before do
      event_start = double("event_start", date_time: busy_start, date: nil)
      event_end   = double("event_end",   date_time: busy_end,   date: nil)
      event       = double("event", start: event_start, end: event_end)
      events_list = double("events_list", items: [event])
      allow(calendar_service).to receive(:list_events).and_return(events_list)
    end

    it "excludes the busy slot and returns the remaining free slots" do
      result = described_class.call(date_range_start: range_start, date_range_end: range_end)

      expect(result).to be_an(Array)
      expect(result.length).to eq(3)
      expect(result.map { |s| s[:start] }).not_to include(Time.parse("2026-04-01 09:00:00 UTC"))
    end
  end

  context "when the Google API raises an error" do
    before do
      allow(calendar_service).to receive(:list_events).and_raise(StandardError, "API unavailable")
    end

    it "returns an empty array without raising" do
      result = described_class.call(date_range_start: range_start, date_range_end: range_end)
      expect(result).to eq([])
    end
  end
end
