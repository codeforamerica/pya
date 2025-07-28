require 'rails_helper'

RSpec.describe VerificationCodeForm do
  let(:params) do
    {
      verification_code: "123456",
    }
  end
  let(:form) {
   VerificationCodeForm.new(
      params,
      contact_info: "test@example.com"
    )
  }

  describe "#valid?" do
    context "when the verification code is present and valid" do

      it "returns true" do
        allow(VerificationCodeService).to receive(:hash_verification_code_with_contact_info)
                                            .with("test@example.com", "123456")
                                            .and_return("hashed_code")

        allow(EmailAccessToken).to receive_message_chain(:lookup, :exists?).and_return(true)

        expect(form.valid?).to be true
      end
    end

    context "when the verification code is present but invalid" do
      it "adds an error and returns false" do
        allow(VerificationCodeService).to receive(:hash_verification_code_with_contact_info)
                                            .with("test@example.com", "123456")
                                            .and_return("hashed_code")

        allow(EmailAccessToken).to receive_message_chain(:lookup, :exists?).and_return(false)

        expect(form.valid?).to be false
        expect(form.errors[:verification_code]).to include(I18n.t("errors.attributes.verification_code.invalid"))
      end
    end

    context "when the verification code is blank" do
      let(:params) {
        {
          verification_code: "",
        }
      }
      it "adds an error and returns false" do
        expect(form.valid?).to be false
        expect(form.errors[:verification_code]).to include(I18n.t("errors.attributes.verification_code.invalid"))
      end
    end

    context "with magic verification code enabled" do
      before do
        allow(Rails.configuration).to receive(:allow_magic_verification_code).and_return(true)
      end
      context "with the magic code" do
        it "is valid" do
          form = described_class.new({ verification_code: "000000" })
          expect(form).to be_valid
        end
      end
    end
  end

  describe "#initialize" do
    it "assigns attributes correctly" do
      expect(form.verification_code).to eq("123456")
      expect(form.contact_info).to eq("test@example.com")
    end
  end
end
