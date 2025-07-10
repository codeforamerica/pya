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

    context "when year is present" do
      let(:year) { "2023" }

      it "is valid" do
        expect(form).to be_valid
      end
    end
  end
end
