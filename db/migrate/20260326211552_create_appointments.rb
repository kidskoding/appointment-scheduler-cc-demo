class CreateAppointments < ActiveRecord::Migration[8.1]
  def change
    create_table :appointments do |t|
      t.string :request
      t.string :status, default: "pending"
      t.text :summary
      t.datetime :scheduled_at
      t.string :attendee_email

      t.timestamps
    end
  end
end
