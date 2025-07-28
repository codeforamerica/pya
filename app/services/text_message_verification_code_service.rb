class TextMessageVerificationCodeService
  def initialize(phone_number:)
    @phone_number = phone_number
  end

  def request_code
    verification_code = SecureRandom.random_number(900_000) + 100_000
    message = "Your 6-digit FileYourStateTaxes verification code is: #{verification_code}. This code will expire after 10 minutes."

    access_token = TextMessageAccessToken.create!(
      sms_phone_number: @phone_number,
      verification_code: verification_code.to_s,
      expires_at: 10.minutes.from_now
    )

    TwilioService.new.send_sms(
      to: @phone_number,
      body: message
    )
    access_token
  end

  def self.request_code(phone_number:)
    new(phone_number: phone_number).request_code
  end
end