# spec/services/text_message_verification_code_service_spec.rb
require "rails_helper"

RSpec.describe TextMessageVerificationCodeService do
  let(:phone_number) { "+18324651680" }
  let(:twilio_service) { instance_double(TwilioService) }
  let(:twilio_response) { double("TwilioResponse", sid: "SMS123456", status: "sent") }

  before do
    allow(TwilioService).to receive(:new).and_return(twilio_service)
    allow(twilio_service).to receive(:send_sms).and_return(twilio_response)
  end

  describe "#request_code" do
    it "creates a TextMessageAccessToken with a 6-digit code" do
      service = described_class.new(phone_number: phone_number)

      expect {
        service.request_code
      }.to change(TextMessageAccessToken, :count).by(1)

      token = TextMessageAccessToken.last
      expect(token.sms_phone_number).to eq(phone_number)
      expect(token.verification_code).to match(/^\d{6}$/)
      expect(token.expires_at).to be_within(1.second).of(10.minutes.from_now)
    end

    it "sends SMS with the correct message format" do
      service = described_class.new(phone_number: phone_number)
      result = service.request_code

      expected_message = "Your 6-digit FileYourStateTaxes verification code is: #{result.verification_code}. This code will expire after 10 minutes."

      expect(twilio_service).to have_received(:send_sms).with(
        to: phone_number,
        body: expected_message
      )
    end

    it "returns the created TextMessageAccessToken" do
      service = described_class.new(phone_number: phone_number)
      result = service.request_code

      expect(result).to be_a(TextMessageAccessToken)
      expect(result).to be_persisted
    end
  end

  describe "message formatting" do
    it "uses the VERIFICATION_MESSAGE constant" do
      service = described_class.new(phone_number: phone_number)
      token = service.request_code

      expected_message = described_class::VERIFICATION_MESSAGE % { code: token.verification_code }

      expect(twilio_service).to have_received(:send_sms).with(
        to: phone_number,
        body: expected_message
      )
    end
  end
end
