require 'rails_helper'

RSpec.describe Appointment, type: :model do
  describe 'default values' do
    it 'has status "pending" by default' do
      appointment = Appointment.new
      expect(appointment.status).to eq('pending')
    end
  end

  describe 'attributes' do
    it 'has a request attribute' do
      appointment = Appointment.new(request: 'Schedule a meeting')
      expect(appointment.request).to eq('Schedule a meeting')
    end

    it 'has a status attribute' do
      appointment = Appointment.new(status: 'confirmed')
      expect(appointment.status).to eq('confirmed')
    end

    it 'has a summary attribute' do
      appointment = Appointment.new(summary: 'Meeting with John')
      expect(appointment.summary).to eq('Meeting with John')
    end

    it 'has a scheduled_at attribute' do
      time = Time.now
      appointment = Appointment.new(scheduled_at: time)
      expect(appointment.scheduled_at).to eq(time)
    end

    it 'has an attendee_email attribute' do
      appointment = Appointment.new(attendee_email: 'john@example.com')
      expect(appointment.attendee_email).to eq('john@example.com')
    end
  end
end
