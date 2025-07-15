require 'rails_helper'

RSpec.describe YearSelectForm do
  describe "validations" do
    subject(:form) { described_class.new(year: year) }

    context "when year is nil" do
      let(:year) { nil }

      it "is invalid" do
        expect(form).not_to be_valid
        expect(form.errors[:year]).to include("can't be blank")
      end
    end

    context "when year is an empty string" do
      let(:year) { "" }

      it "is invalid" do
        expect(form).not_to be_valid
        expect(form.errors[:year]).to include("can't be blank")
      end
    end

    context "when year is invalid" do
      let(:year) { "2022" }

      it "is invalid" do
        expect(form).not_to be_valid
        expect(form.errors[:year]).to include("is not included in the list")
      end
    end

    context "when year is 2023" do
      let(:year) { "2023" }

      it "is valid" do
        expect(form).to be_valid
      end
    end

    context "when year is 2024" do
      let(:year) { "2024" }

      it "is valid" do
        expect(form).to be_valid
      end
    end
  end
end
