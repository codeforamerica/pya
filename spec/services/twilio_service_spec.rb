# spec/services/twilio_service_spec.rb
require 'rails_helper'

RSpec.describe TwilioService do
  describe "#send_sms" do
    let(:twilio_service) { described_class.new }
    let(:fake_client) { double }
    let(:fake_messages_resource) { double }
    let(:fake_message) { double(sid: "SMS123", status: "sent") }

    before do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with('TWILIO_ACCOUNT_SID').and_return('test_account_sid')
      allow(ENV).to receive(:[]).with('TWILIO_AUTH_TOKEN').and_return('test_auth_token')
      allow(ENV).to receive(:[]).with('TWILIO_MESSAGING_SERVICE').and_return('test_messaging_sid')

      allow(Twilio::REST::Client).to receive(:new).and_return(fake_client)
      allow(fake_client).to receive(:messages).and_return(fake_messages_resource)
      allow(fake_messages_resource).to receive(:create).and_return(fake_message)
    end

    it "sends a message using the twilio client" do
      actual = twilio_service.send_sms(
        to: "+15855551212",
        body: "Any message content"
      )

      expect(actual).to eq(fake_message)
      expect(fake_messages_resource).to have_received(:create).with(
        messaging_service_sid: "test_messaging_sid",
        to: "+15855551212",
        body: "Any message content"
      )
    end

    it "can send any type of message" do
      twilio_service.send_sms(
        to: "+15855551212",
        body: "This is a different message"
      )

      expect(fake_messages_resource).to have_received(:create).with(
        hash_including(body: "This is a different message")
      )
    end

    context "when twilio raises an error" do
      before do
        fake_response = double(
          "response",
          status_code: 500,
          body: { "message" => "Something went wrong" }
        )
        error = Twilio::REST::RestError.new("Twilio Error", fake_response)

        allow(fake_messages_resource).to receive(:create)
                                           .and_raise(error)
      end
    end
  end
end