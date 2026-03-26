module Tools
  class SendInvite
    def self.call(attendee_email:, event_title:, start_time:)
      Rails.logger.info("[Tools::SendInvite] Sending invite to #{attendee_email} for '#{event_title}' at #{start_time}")

      { success: true, message: "Invite sent to #{attendee_email}" }
    end
  end
end
