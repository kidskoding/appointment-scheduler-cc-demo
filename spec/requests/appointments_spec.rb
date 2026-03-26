require 'rails_helper'

RSpec.describe "Appointments", type: :request do
  describe "GET /" do
    it "returns 200" do
      get root_path
      expect(response).to have_http_status(200)
    end
  end

  describe "POST /appointments" do
    it "creates an Appointment with status pending and redirects to root" do
      expect {
        post appointments_path, params: { request: "Schedule a 30 min meeting with John next week" }
      }.to change(Appointment, :count).by(1)

      appointment = Appointment.last
      expect(appointment.request).to eq("Schedule a 30 min meeting with John next week")
      expect(appointment.status).to eq("pending")

      expect(response).to redirect_to(root_path)
    end
  end
end
