class TextMessageVerificationCodeService
  def initialize(phone_number:, locale: :en, visitor_id:)
    @phone_number = phone_number
    @locale = locale
    @visitor_id = visitor_id
  end

  def request_code
    verification_code, access_token = TextMessageAccessToken.generate!(sms_phone_number: @phone_number)
    message_arguments = {
      to: @phone_number,
      body: I18n.t("text_message.verification_code",
                   locale: @locale,
                   verification_code: verification_code
      ).strip
    }.compact
    twilio_response = TwilioService.send_message(**message_arguments)
    VerificationTextMessage.create!(
      text_message_access_token: access_token,
      visitor_id: @visitor_id,
      twilio_sid: twilio_response&.sid
    )
  end

  private

  def self.request_code(**args)
    new(**args).request_code
  end
end
