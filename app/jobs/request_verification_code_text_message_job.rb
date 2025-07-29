class RequestVerificationCodeTextMessageJob < ApplicationJob 
  def perform(phone_number:, locale:)
    TextMessageVerificationCodeService.request_code(
      phone_number: phone_number,
      locale: locale
    )
  end

  def priority
    PRIORITY_HIGH
  end
end
