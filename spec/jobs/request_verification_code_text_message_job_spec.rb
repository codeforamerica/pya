require "rails_helper"

RSpec.describe RequestVerificationCodeTextMessageJob, type: :job do
  before do
    allow(TextMessageVerificationCodeService).to receive(:request_code)
  end

  describe "#perform" do
    it "requests a generated code from the TextMessageVerificationCodeService" do
      RequestVerificationCodeTextMessageJob.perform_now(phone_number: "+15105551234", locale: "en")

      expect(TextMessageVerificationCodeService).to have_received(:request_code).with(
        phone_number: "+15105551234",
        locale: "en"
      )
    end
  end
end


