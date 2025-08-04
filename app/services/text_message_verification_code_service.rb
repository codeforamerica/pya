class TextMessageVerificationCodeService
  def initialize(phone_number:, locale: :en)
    @phone_number = phone_number
    @locale = locale
  end

  def request_code
    logger.info "[TextMessageVerificationCodeService] Generating verification code for: #{@phone_number}"

    verification_code, access_token = TextMessageAccessToken.generate!(sms_phone_number: @phone_number)

    message_arguments = {
      to: @phone_number,
      body: I18n.t("text_message.verification_code",
                   locale: @locale,
                   verification_code: verification_code
      ).strip
    }.compact

    logger.info "[TextMessageVerificationCodeService] Sending SMS to: #{@phone_number} with body: #{message_arguments[:body]}"

    TwilioService.new.send_message(**message_arguments)

    logger.info "[TextMessageVerificationCodeService] SMS sent successfully to: #{@phone_number}"

    access_token
  rescue => e
    logger.error "[TextMessageVerificationCodeService] Failed to send SMS to: #{@phone_number} — #{e.class}: #{e.message}"
    raise
  end

  private

  def self.request_code(**args)
    new(**args).request_code
  end
end
