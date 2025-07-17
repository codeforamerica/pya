require 'rails_helper'

RSpec.describe ContactPreferenceForm do
  let(:intake) { create :state_file_archived_intake }

  describe "#save" do
    let(:valid_params) do
      { contact_preference: "email" }
    end

    it "saves the contact preference to the intake" do
      form = described_class.new(valid_params.merge(state_file_archived_intake: intake))
      expect {
        form.save
      }.to change { intake.reload.contact_preference }.from("unfilled").to("email")
    end
  end
end
