class EmailVerificationCodeJob < ApplicationJob
  retry_on Mailgun::CommunicationError

  def perform(email_address:, locale:)
    EmailVerificationCodeService.request_code(
      email_address: email_address,
      locale: locale
    )
  rescue
    raise
  end

  def priority
    PRIORITY_HIGH - 1 # Subtracting one to push to the top of the queue
  end
end
