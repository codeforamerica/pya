# spec/controllers/base_controller_spec.rb
require "rails_helper"

RSpec.describe BaseController, type: :controller do
  include Devise::Test::ControllerHelpers

  before do
    request.env["devise.mapping"] = Devise.mappings[:state_file_archived_intake]
    allow(controller).to receive(:root_path).and_return("/")
  end

  let(:tax_year) { 2024 }
  let(:email_address) { "test@example.com" }
  let(:phone_number) { "5551234567" }

  let!(:email_intake) do
    create(:state_file_archived_intake,
      email_address: email_address,
      tax_year: tax_year)
  end

  let!(:phone_intake) do
    create(:state_file_archived_intake,
      phone_number: phone_number,
      tax_year: tax_year)
  end

  describe "#create_and_login_state_file_archived_intake" do
    before { session[:year_selected] = tax_year }

    context "when email_address is provided" do
      it "finds the intake by email and signs it in" do
        controller.create_and_login_state_file_archived_intake(email_address: email_address)
        expect(controller.current_state_file_archived_intake).to eq(email_intake)
      end

      it "matches email case-insensitively" do
        controller.create_and_login_state_file_archived_intake(email_address: "TeSt@ExAmPlE.CoM")
        expect(controller.current_state_file_archived_intake).to eq(email_intake)
      end

      it "does not match an intake with the same email in a different tax_year" do
        create(:state_file_archived_intake, email_address: email_address, tax_year: tax_year + 1)
        controller.create_and_login_state_file_archived_intake(email_address: email_address)
        expect(controller.current_state_file_archived_intake).to eq(email_intake)
      end

      it "creates a new intake scoped to tax_year if email does not exist for that year" do
        create(:state_file_archived_intake, email_address: "new_email@domain.com", tax_year: tax_year + 1)

        expect {
          controller.create_and_login_state_file_archived_intake(email_address: "new_email@domain.com")
        }.to change { StateFileArchivedIntake.count }.by(1)

        new_intake = controller.current_state_file_archived_intake
        expect(new_intake.email_address).to eq("new_email@domain.com")
        expect(new_intake.phone_number).to be_nil
        expect(new_intake.tax_year).to eq(tax_year)
      end

      it "creates a new intake if email does not exist" do
        expect {
          controller.create_and_login_state_file_archived_intake(email_address: "brand_new@domain.com")
        }.to change { StateFileArchivedIntake.count }.by(1)

        new_intake = controller.current_state_file_archived_intake
        expect(new_intake.email_address).to eq("brand_new@domain.com")
        expect(new_intake.phone_number).to be_nil
      end
    end

    context "when phone_number is provided" do
      it "finds the intake by phone and signs it in" do
        controller.create_and_login_state_file_archived_intake(phone_number: phone_number)
        expect(controller.current_state_file_archived_intake).to eq(phone_intake)
      end

      it "does not match an intake with the same phone in a different tax_year" do
        create(:state_file_archived_intake, phone_number: phone_number, tax_year: tax_year + 1)
        controller.create_and_login_state_file_archived_intake(phone_number: phone_number)
        expect(controller.current_state_file_archived_intake).to eq(phone_intake)
      end

      it "creates a new intake scoped to tax_year if phone number does not exist for that year" do
        create(:state_file_archived_intake, phone_number: "9998887777", tax_year: tax_year + 1)

        expect {
          controller.create_and_login_state_file_archived_intake(phone_number: "9998887777")
        }.to change { StateFileArchivedIntake.count }.by(1)

        new_intake = controller.current_state_file_archived_intake
        expect(new_intake.phone_number).to eq("9998887777")
        expect(new_intake.email_address).to be_nil
        expect(new_intake.tax_year).to eq(tax_year)
      end

      it "creates a new intake if phone number does not exist" do
        expect {
          controller.create_and_login_state_file_archived_intake(phone_number: "1112223333")
        }.to change { StateFileArchivedIntake.count }.by(1)

        new_intake = controller.current_state_file_archived_intake
        expect(new_intake.phone_number).to eq("1112223333")
        expect(new_intake.email_address).to be_nil
      end
    end

    context "when neither phone_number nor email_address is provided" do
      it "redirects to root and does not sign in or create" do
        expect(controller).to receive(:redirect_to).with("/")
        expect {
          controller.create_and_login_state_file_archived_intake
        }.not_to change { StateFileArchivedIntake.count }
        expect(controller.current_state_file_archived_intake).to be_nil
      end
    end

    context "when year_selected is nil" do
      before { session[:year_selected] = nil }

      it "redirects to root and does not create" do
        expect(controller).to receive(:redirect_to).with("/")
        expect {
          controller.create_and_login_state_file_archived_intake(email_address: "y0@ex.com")
        }.not_to change { StateFileArchivedIntake.count }
        expect(controller.current_state_file_archived_intake).to be_nil
      end
    end
  end
end
