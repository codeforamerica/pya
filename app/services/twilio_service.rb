class TwilioService
  def initialize
    @client = Twilio::REST::Client.new(
      ENV["TWILIO_ACCOUNT_SID"],
      ENV["TWILIO_AUTH_TOKEN"]
    )
    @messaging_service_sid = ENV["TWILIO_MESSAGING_SERVICE"]
  end

  def send_message(to:, body:)
    @client.messages.create(
      messaging_service_sid: @messaging_service_sid,
      to: to,
      body: body
    )
  rescue Twilio::REST::RestError => e
    Rails.logger.error "Failed to send SMS: #{e.message}"
    raise
  end
end
