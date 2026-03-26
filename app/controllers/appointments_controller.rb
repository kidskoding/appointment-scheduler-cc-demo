class AppointmentsController < ApplicationController
  def index
    @appointments = Appointment.order(created_at: :desc)
  end

  def create
    Appointment.create!(
      request: params[:request],
      status: "pending"
    )
    redirect_to root_path
  end
end
