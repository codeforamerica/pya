require 'rails_helper'

RSpec.describe VerificationCodeForm do
  describe "validations" do
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

    context "without magic verification code enabled" do
      before do
        allow(Rails.configuration).to receive(:allow_magic_verification_code).and_return(false)
      end
      context "with the magic code" do
        it "is not valid" do
          form = described_class.new({ verification_code: "000000" })
          expect(form).not_to be_valid
        end
      end
    end
  end
end
