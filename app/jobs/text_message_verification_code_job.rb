class TextMessageVerificationCodeJob < ApplicationJob
  def perform(phone_number:, locale:)
    TextMessageVerificationCodeService.request_code(
      phone_number: phone_number,
      locale: locale
    )

    Rails.logger.info "[TextMessageVerificationCodeJob] Successfully completed for: #{phone_number}"
  rescue => e
    Rails.logger.error "[TextMessageVerificationCodeJob] Failed for: #{phone_number} — Error: #{e.class} - #{e.message}"
    raise
  end

  def priority
    PRIORITY_HIGH - 1 # Subtracting one to push to the top of the queue
  end
end
