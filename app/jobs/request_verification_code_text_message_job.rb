class RequestVerificationCodeTextMessageJob < ApplicationJob 
  def perform(phone_number:, locale:, visitor_id:)
    TextMessageVerificationCodeService.request_code(
      phone_number: phone_number,
      locale: locale,
      visitor_id: visitor_id,
    )
  end

  def priority
    PRIORITY_HIGH
  end
end
