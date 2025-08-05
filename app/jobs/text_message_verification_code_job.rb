class TextMessageVerificationCodeJob < ApplicationJob
  def perform(phone_number:, locale:)
    TextMessageVerificationCodeService.request_code(
      phone_number: phone_number,
      locale: locale
    )
  end

  def priority
    PRIORITY_HIGH - 1 # Subtracting one to push to the top of the queue
  end
end
