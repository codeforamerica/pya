require "rails_helper"

RSpec.describe EmailAddressController, type: :controller do
  describe "GET #edit" do
    it "renders the edit template with a new EmailAddressForm" do
      get :edit

      expect(assigns(:form)).to be_a(EmailAddressForm)
      expect(response).to render_template(:edit)
    end
  end

  describe "POST #update" do
    let(:valid_email_address) { "test@example.com" }
    let(:mixed_case_email_address) { "Test@Example.COM" }
    let(:invalid_email_address) { "" }

    context "when the form is valid" do
      context "and an archived intake exists with an email address" do
        let!(:archived_intake) { create :state_file_archived_intake, email_address: valid_email_address }
        # TODO update this test with logging and the proper redirects https://codeforamerica.atlassian.net/browse/FYST-2088
        it "creates a request, updates the session and redirects to the root path" do
          post :update, params: {
            email_address_form: { email_address: valid_email_address }
          }
          expect(assigns(:form)).to be_valid
          active_archived_intake = controller.send(:current_archived_intake)
          expect(active_archived_intake.email_address).to eq(valid_email_address)
          expect(active_archived_intake.hashed_ssn).to eq(archived_intake.hashed_ssn)
          expect(active_archived_intake.id).to eq(archived_intake.id)

          expect(session[:ssn_verified]).to be(false)
          expect(session[:mailing_verified]).to be(false)
          expect(session[:code_verified]).to be(false)
          expect(session[:email_address]).to eq(valid_email_address)

          expect(response).to redirect_to(edit_verification_code_path)
        end

        it "matches email case insensitively" do
          post :update, params: {
            email_address_form: { email_address: mixed_case_email_address }
          }

          expect(assigns(:form)).to be_valid

          active_archived_intake = controller.send(:current_archived_intake)
          expect(active_archived_intake.email_address).to eq(valid_email_address)
          expect(active_archived_intake.hashed_ssn).to eq(archived_intake.hashed_ssn)
          expect(active_archived_intake.id).to eq(archived_intake.id)

          expect(response).to redirect_to(edit_verification_code_path)
        end
      end

      context "and an archived intake does not exist with the email address" do
        it "creates an access log, creates a new archived intake without a ssn or address, and redirects to the verification code page" do
          post :update, params: {
            email_address_form: { email_address: valid_email_address }
          }
          expect(assigns(:form)).to be_valid

          active_archived_intake = controller.send(:current_archived_intake)
          expect(active_archived_intake.email_address).to eq(valid_email_address)
          expect(active_archived_intake.hashed_ssn).to eq(nil)
          expect(active_archived_intake.full_address).to eq("")

          expect(response).to redirect_to(edit_verification_code_path)
        end

        it "resets verification session variables and sets email" do
          post :update, params: {
            email_address_form: { email_address: valid_email_address }
          }

          expect(assigns(:form)).to be_valid

          expect(session[:ssn_verified]).to be(false)
          expect(session[:mailing_verified]).to be(false)
          expect(session[:code_verified]).to be(false)

          expect(session[:email_address]).to eq(valid_email_address)
        end
      end
    end

    context "when the form is invalid" do
      it "renders the edit template" do
        post :update, params: {
          email_address_form: { email_address: invalid_email_address }
        }

        expect(assigns(:form)).not_to be_valid

        expect(response).to render_template(:edit)
      end
    end
  end
end
