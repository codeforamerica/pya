# == Schema Information
#
# Table name: text_message_access_tokens
#
#  id               :bigint           not null, primary key
#  sms_phone_number :string           not null
#  token            :string           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_text_message_access_tokens_on_token  (token)
#
require "rails_helper"

describe TextMessageAccessToken do
  describe "#valid?" do
    describe "required fields" do
      it "adds an error for any missing required fields" do
        access_token = described_class.new

        expect(access_token).not_to be_valid
        expect(access_token.errors).to include(:sms_phone_number)
        expect(access_token.errors).to include(:token)
      end

      it "is valid with all required fields" do
        access_token = described_class.new(
          token: "a8sd7hf98a7sdhf8a",
          sms_phone_number: "+15005550006",
          )
        expect(access_token).to be_valid
      end
    end

    describe "#sms_phone_number" do
      let(:access_token) { build :text_message_access_token, sms_phone_number: sms_phone_number }
      context "with an invalid phone number" do
        let(:sms_phone_number) { "500 5550" }

        it "is not valid" do
          expect(access_token).not_to be_valid
          expect(access_token.errors).to include :sms_phone_number
        end
      end

      context "with a valid phone number" do
        let(:sms_phone_number) { "+15005550006" }

        it "is valid" do
          expect(access_token).to be_valid
        end
      end
    end
  end

  describe "before_create" do
    let(:phone_number) { "+18324658840" }
    before do
      5.times do
        create :text_message_access_token, sms_phone_number: phone_number
      end
    end

    it "ensures there are no more than 5 active tokens" do
      last = create :text_message_access_token, sms_phone_number: phone_number
      expect(described_class.where(sms_phone_number: phone_number).count).to eq(5)
      expect(described_class.where(sms_phone_number: phone_number)).to include last
    end
  end

  describe "generate!" do
    let(:phone_number) { "+15125551234" }
    let(:verification_code) { "123456" }
    let(:hashed_verification_code) { "a_hashed_verification_code" }
    before do
      allow(VerificationCodeService).to receive(:generate).and_return [ verification_code, hashed_verification_code ]
    end

    it "creates an instance of the class, persisting the hashed code and returns the hashed and raw token" do
      response = described_class.generate!(sms_phone_number: phone_number)
      expect(response[0]).to eq "123456"
      object = TextMessageAccessToken.last
      expect(response[1]).to eq object
      expect(object.token).to eq Devise.token_generator.digest(described_class, :token, hashed_verification_code)
      expect(object.sms_phone_number).to eq phone_number
    end
  end

  describe "lookup scope" do
    let!(:expired_token) { create :text_message_access_token, created_at: 15.minutes.ago, token: Devise.token_generator.digest(TextMessageAccessToken, :token, "raw_token") }
    let!(:fresh_token) { create :text_message_access_token, created_at: 5.minutes.ago, token: Devise.token_generator.digest(TextMessageAccessToken, :token, "raw_token") }

    it "returns codes that have not expired" do
      expect(described_class.lookup("raw_token")).to match_array([ fresh_token ])
    end
  end
end
