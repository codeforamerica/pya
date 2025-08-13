require "rails_helper"

RSpec.describe PhoneNumberForm do
  let(:valid_params) do
    {phone_number: "4153334444"}
  end

  describe "#normalize_phone_number" do
    it "normalizes the phone number to e164 format" do
      form = described_class.new({phone_number: "4153334444"})
      form.normalize_phone_number
      expect(form.phone_number).to eq "+14153334444"
    end
  end

  describe "validations" do
    context "with an invalid phone number" do
      it "is not valid" do
        form = described_class.new({phone_number: "55555"})
        expect(form).not_to be_valid
      end
    end

    context "with a valid phone number" do
      it "is valid" do
        form = described_class.new(valid_params)
        expect(form).to be_valid
      end
    end
  end
end
