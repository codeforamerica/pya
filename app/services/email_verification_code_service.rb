class EmailVerificationCodeService
  def initialize(email_address:, locale: :en)
    @email_address = email_address
    @locale = locale
  end

  def request_code
    Rails.logger.info "[EmailVerificationCodeService] Generating verification code for: #{@email_address}"

    verification_code, = EmailAccessToken.generate!(email_address: @email_address)

    Rails.logger.info "[EmailVerificationCodeService] Sending verification email to: #{@email_address}"

    VerificationCodeMailer.archived_intake_verification_code(
      to: @email_address,
      verification_code: verification_code,
      locale: @locale
    ).deliver_now

    Rails.logger.info "[EmailVerificationCodeService] Email sent to: #{@email_address}"
  rescue => e
    Rails.logger.error "[EmailVerificationCodeService] Error sending code to: #{@email_address} — #{e.class}: #{e.message}"
    raise
  end

  def self.request_code(**args)
    new(**args).request_code
  end
end
