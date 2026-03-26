require "service_helper"

RSpec.describe Tools::SendInvite do
  let(:attendee_email) { "alice@example.com" }
  let(:event_title)    { "Project Kickoff" }
  let(:start_time)     { "2026-04-01T14:00:00Z" }

  describe ".call" do
    subject(:result) do
      described_class.call(
        attendee_email: attendee_email,
        event_title:    event_title,
        start_time:     start_time
      )
    end

    it "returns a hash with success: true" do
      expect(result[:success]).to be true
    end

    it "returns a message mentioning the attendee email" do
      expect(result[:message]).to include(attendee_email)
    end

    it "returns a hash with a :message key" do
      expect(result).to include(:message)
    end

    it "does not raise an error" do
      expect { result }.not_to raise_error
    end
  end
end
