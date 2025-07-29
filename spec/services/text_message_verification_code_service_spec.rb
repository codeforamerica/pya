require "rails_helper"

describe TextMessageVerificationCodeService do
  let(:twilio_service) { instance_double TwilioService }
  let(:phone_number) { "+18324651680" }
  let(:locale) { :en }
  let(:visitor_id) { "visitor_id_1" }
  let(:params) do
    {
      phone_number: phone_number,
      locale: locale,
      visitor_id: visitor_id
    }
  end

  describe "#initialize" do
    it "sets the instance variables correctly" do
      service = described_class.new(**params)

      expect(service.instance_variable_get(:@phone_number)).to eq(phone_number)
      expect(service.instance_variable_get(:@locale)).to eq(locale)
      expect(service.instance_variable_get(:@visitor_id)).to eq(visitor_id)
    end

    it "defaults locale to :en" do
      service = described_class.new(phone_number: phone_number, visitor_id: visitor_id)

      expect(service.instance_variable_get(:@locale)).to eq(:en)
    end
  end

  describe ".request_code" do
    let(:access_token) { create :text_message_access_token }
    let(:verification_code) { "123456" }

    before do
      allow(TwilioService).to receive(:new).and_return(twilio_service)
      allow(TextMessageAccessToken).to receive(:generate!).and_return([ verification_code, access_token ])
      allow(twilio_service).to receive(:send_message)
    end

    it "generates a verification code and access token" do
      described_class.request_code(**params)

      expect(TextMessageAccessToken).to have_received(:generate!).with(
        sms_phone_number: phone_number
      )
    end

    it "sends a text message with the verification code" do
      described_class.request_code(**params)
      expected_body = "Your 6-digit FileYourStateTaxes verification code is: 123456. This code will expire after 10 minutes"

      expect(twilio_service).to have_received(:send_message).with(
        to: phone_number,
        body: expected_body
      )
    end

    it "returns the access token" do
      result = described_class.request_code(**params)

      expect(result).to eq(access_token)
    end

    context "when using instance method" do
      it "creates an instance and calls request_code" do
        service = described_class.new(**params)
        result = service.request_code

        expect(result).to eq(access_token)
        expect(TextMessageAccessToken).to have_received(:generate!)
        expect(twilio_service).to have_received(:send_message)
      end
    end

    context "when TwilioService fails" do
      before do
        allow(twilio_service).to receive(:send_message).and_raise(Twilio::REST::RestError.new(400, double(body: {}, status_code: 21211)))
      end

      it "allows the error to come up" do
        expect {
          described_class.request_code(**params)
        }.to raise_error(Twilio::REST::RestError)
      end
    end
  end
end
