require "rails_helper"

RSpec.describe EmailVerificationCodeJob, type: :job do
  before do
    allow(EmailVerificationCodeService).to receive(:request_code)
  end

  describe "#perform" do
    context "with email_address, and locale params" do
      it "requests a verification code by email using those params" do
        EmailVerificationCodeJob.perform_now(email_address: "client@example.com", locale: "es")

        expect(EmailVerificationCodeService).to have_received(:request_code).with(
          email_address: "client@example.com",
          locale: "es"
        )
      end
    end
  end
end
