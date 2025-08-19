require "rails_helper"

RSpec.describe IdentificationNumberController, type: :controller do
  let(:intake_ssn) { "123456789" }
  let(:invalid_ssn) { "212345678" }
  let(:intake_request_email) { "ohhithere@gmail.com" }
  let(:hashed_ssn) { SsnHashingService.hash(intake_ssn) }
  let!(:archived_intake) { create(:state_file_archived_intake, hashed_ssn: hashed_ssn, email_address: intake_request_email, failed_attempts: 0) }

  before do
    session[:code_verified] = true
    allow(controller).to receive(:current_archived_intake).and_return(archived_intake)
    session[:email_address] = "ohhithere@example.com"
  end

  describe "GET #edit" do
    it_behaves_like "archived intake locked", action: :edit, method: :get

    it "renders the edit template with a new IdentificationNumberForm" do
      get :edit

      expect(assigns(:form)).to be_a(IdentificationNumberForm)
      expect(response).to render_template(:edit)
    end

    it "redirects to root if code verification was not completed" do
      session[:code_verified] = nil
      get :edit

      expect(response).to redirect_to(root_path)
    end
  end

  describe "PATCH #update" do
    context "with a valid ssn" do
      it "redirects to the mailing address validation page" do
        post :update, params: {
          identification_number_form: {ssn: intake_ssn}
        }
        expect(assigns(:form)).to be_valid

        expect(session[:ssn_verified]).to eq(true)

        expect(archived_intake.reload.failed_attempts).to eq(0)

        expect(response).to redirect_to(root_path)
        # TODO: update to mailing address page
      end

      it "resets failed attempts to zero even if one failed attempt has already been made" do
        archived_intake.update!(failed_attempts: 1)

        post :update, params: {
          identification_number_form: {ssn: intake_ssn}
        }

        expect(assigns(:form)).to be_valid
        expect(archived_intake.reload.failed_attempts).to eq(0)
      end
    end

    context "with an invalid ssn" do
      before do
        allow_any_instance_of(VerificationCodeForm).to receive(:valid?).and_return(false)
      end

      it "increments failed_attempts, and re-renders edit on first failed attempt" do
        post :update, params: {identification_number_form: {ssn: invalid_ssn}}
        expect(archived_intake.reload.failed_attempts).to eq(1)
        expect(response).to render_template(:edit)
      end

      it "locks the account and redirects to root path after multiple failed attempts" do
        archived_intake.update!(failed_attempts: 1)

        post :update, params: {identification_number_form: {ssn: invalid_ssn}}

        expect(archived_intake.reload.failed_attempts).to eq(2)
        expect(archived_intake.reload.access_locked?).to be_truthy
        expect(response).to redirect_to(knock_out_path)
      end
    end
  end
end
