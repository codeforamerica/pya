require 'rails_helper'

describe TwilioService do
  let(:twilio_service) { TwilioService.new }
  let(:fake_client) { double }
  let(:fake_messages_resource) { double }
  let(:fake_message) { double }

  before do
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with("TWILIO_ACCOUNT_SID").and_return("test_account_sid")
    allow(ENV).to receive(:[]).with("TWILIO_AUTH_TOKEN").and_return("test_auth_token")
    allow(ENV).to receive(:[]).with("TWILIO_MESSAGING_SERVICE").and_return("test_messaging_service")

    allow(Twilio::REST::Client).to receive(:new).and_return(fake_client)
    allow(fake_client).to receive(:messages).and_return(fake_messages_resource)
    allow(fake_message).to receive(:sid).and_return("SM123456789")
  end

  describe "#initialize" do
    it "creates a Twilio client with environment credentials" do
      TwilioService.new

      expect(Twilio::REST::Client).to have_received(:new).with(
        "test_account_sid",
        "test_auth_token"
      )
    end

    it "sets the messaging service SID from environment" do
      service = TwilioService.new

      expect(service.instance_variable_get(:@messaging_service_sid)).to eq("test_messaging_service")
    end
  end

  describe "#send_message" do
    before do
      allow(fake_messages_resource).to receive(:create).and_return(fake_message)
    end

    it "sends a message using the Twilio client" do
      result = twilio_service.send_message(
        to: "+15551234567",
        body: "Test message"
      )

      expect(result).to eq(fake_message)
      expect(fake_messages_resource).to have_received(:create).with(
        messaging_service_sid: "test_messaging_service",
        to: "+15551234567",
        body: "Test message"
      )
    end

    it "handles messages with special characters" do
      twilio_service.send_message(
        to: "+15551234567",
        body: "Hello! How are you? 🙂"
      )

      expect(fake_messages_resource).to have_received(:create).with(
        messaging_service_sid: "test_messaging_service",
        to: "+15551234567",
        body: "Hello! How are you? 🙂"
      )
    end

    context "when Twilio returns an error" do
      let(:error_response) { double(body: { message: "Invalid phone number" }, status_code: 21211) }
      let(:twilio_error) { Twilio::REST::RestError.new(400, error_response) }

      before do
        allow(fake_messages_resource).to receive(:create).and_raise(twilio_error)
        allow(Rails.logger).to receive(:error)
      end

      it "logs the error and re-raises the exception" do
        expect {
          twilio_service.send_message(
            to: "+invalid",
            body: "Test message"
          )
        }.to raise_error(Twilio::REST::RestError)

        expect(Rails.logger).to have_received(:error).with(a_string_starting_with("Failed to send SMS:"))
      end
    end

    context "when environment variables are missing" do
      before do
        allow(ENV).to receive(:[]).with("TWILIO_ACCOUNT_SID").and_return(nil)
        allow(ENV).to receive(:[]).with("TWILIO_AUTH_TOKEN").and_return(nil)
        allow(ENV).to receive(:[]).with("TWILIO_MESSAGING_SERVICE").and_return(nil)
      end

      it "creates client with nil values" do
        TwilioService.new

        expect(Twilio::REST::Client).to have_received(:new).with(nil, nil)
      end
    end
  end
end
