require "rails_helper"

RSpec.describe IdentificationNumberController, type: :controller do
  include Devise::Test::ControllerHelpers

  let(:intake_ssn) { "123456789" }
  let(:invalid_ssn) { "212345678" }
  let(:intake_request_email) { "ohhithere@gmail.com" }
  let(:hashed_ssn) { SsnHashingService.hash(intake_ssn) }

  let!(:archived_intake) do
    create(
      :state_file_archived_intake,
      hashed_ssn: hashed_ssn,
      email_address: intake_request_email,
      failed_attempts: 0
    )
  end

  before do
    request.env["devise.mapping"] = Devise.mappings[:state_file_archived_intake]

    sign_in archived_intake

    session[:code_verified] = true

    allow(EventLogger).to receive(:log)
  end

  describe "GET #edit" do
    it "renders the edit template with a new IdentificationNumberForm bound to the current intake" do
      get :edit

      expect(assigns(:form)).to be_a(IdentificationNumberForm)
      expect(response).to render_template(:edit)
    end

    it "redirects to root if code verification was not completed and logs unauthorized attempt" do
      session[:code_verified] = nil

      get :edit

      expect(EventLogger).to have_received(:log).with("unauthorized ssn attempt", archived_intake.id)
      expect(response).to redirect_to(root_path)
    end
  end

  describe "PATCH #update" do
    context "with a valid ssn" do
      it "redirects to mailing address validation, logs success + next challenge, resets failed attempts, and sets ssn_verified" do
        expect(EventLogger).to receive(:log).with("correct ssn challenge", archived_intake.id).ordered
        expect(EventLogger).to receive(:log).with("issued mailing address challenge", archived_intake.id).ordered

        post :update, params: {identification_number_form: {ssn: intake_ssn}}

        expect(assigns(:form)).to be_valid
        expect(session[:ssn_verified]).to eq(true)
        expect(archived_intake.reload.failed_attempts).to eq(0)
        expect(response).to redirect_to(edit_mailing_address_validation_path)
      end

      it "resets failed attempts to zero even if one failed attempt has already been made" do
        archived_intake.update!(failed_attempts: 1)

        expect(EventLogger).to receive(:log).with("correct ssn challenge", archived_intake.id).ordered
        expect(EventLogger).to receive(:log).with("issued mailing address challenge", archived_intake.id).ordered

        post :update, params: {identification_number_form: {ssn: intake_ssn}}

        expect(assigns(:form)).to be_valid
        expect(archived_intake.reload.failed_attempts).to eq(0)
      end
    end

    context "with an invalid ssn" do
      it "increments failed_attempts, logs incorrect attempt, and re-renders edit on first failed attempt" do
        expect(EventLogger).to receive(:log).with("incorrect ssn challenge", archived_intake.id)

        post :update, params: {identification_number_form: {ssn: invalid_ssn}}

        expect(archived_intake.reload.failed_attempts).to eq(1)
        expect(response).to render_template(:edit)
      end
      context "with a recent failed attempt" do
        let!(:archived_intake) { create(:state_file_archived_intake, :with_recent_failed_attempt) }
        it "locks the account after subsequent failures, logs lockout begin, and redirects to knock_out" do
          expect(EventLogger).to receive(:log).with("incorrect ssn challenge", archived_intake.id).ordered
          expect(EventLogger).to receive(:log).with("client lockout begin", archived_intake.id).ordered

          post :update, params: {identification_number_form: {ssn: invalid_ssn}}

          archived_intake.reload
          expect(archived_intake.failed_attempts).to eq(2)
          expect(archived_intake.access_locked?).to be_truthy
          expect(response).to redirect_to(knock_out_path)
        end
      end
    end

    context "when code verification is missing" do
      it "redirects to root (guard in before_action) and logs unauthorized attempt" do
        session[:code_verified] = nil

        post :update, params: {identification_number_form: {ssn: intake_ssn}}

        expect(EventLogger).to have_received(:log).with("unauthorized ssn attempt", archived_intake.id)
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
