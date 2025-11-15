class TextMessageVerificationCodeService
  def initialize(phone_number:, locale: :en)
    @phone_number = phone_number
    @locale = locale
  end

  def request_code
    verification_code, access_token = TextMessageAccessToken.generate!(sms_phone_number: @phone_number)

    message_arguments = {
      to: @phone_number,
      body: I18n.t("mailers.archived_intake_verification_code.body_text",
        locale: @locale,
        verification_code: verification_code).strip
    }.compact

    TwilioService.new.send_message(**message_arguments)

    access_token
  end

  private_class_method

  def self.request_code(**args)
    new(**args).request_code
  end
end
