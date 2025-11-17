# spec/controllers/email_address_controller_spec.rb
require "rails_helper"

RSpec.describe EmailAddressController, type: :controller do
  include Devise::Test::ControllerHelpers

  before do
    request.env["devise.mapping"] = Devise.mappings[:state_file_archived_intake]
  end

  describe "GET #edit" do

    it "signs out any existing state_file_archived_intake and resets verification flags" do
      intake = create(:state_file_archived_intake)
      sign_in intake

      session[:ssn_verified]     = true
      session[:mailing_verified] = true
      session[:code_verified]    = true

      get :edit

      expect(controller.current_state_file_archived_intake).to be_nil
      
      expect(session[:ssn_verified]).to eq(false)
      expect(session[:mailing_verified]).to eq(false)
      expect(session[:code_verified]).to eq(false)

      expect(assigns(:form)).to be_a(EmailAddressForm)
      expect(response).to render_template(:edit)
    end

    it "initializes a new EmailAddressForm and sets verification flags to false when no one is signed in" do
      session[:ssn_verified]     = true
      session[:mailing_verified] = nil
      session[:code_verified]    = true

      get :edit

      expect(assigns(:form)).to be_a(EmailAddressForm)
      expect(response).to render_template(:edit)

      expect(session[:ssn_verified]).to eq(false)
      expect(session[:mailing_verified]).to eq(false)
      expect(session[:code_verified]).to eq(false)
    end

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
      before { session[:year_selected] = "2023" }

      context "and an archived intake exists with that email (case-insensitive)" do
        let!(:archived_intake) do
          create(:state_file_archived_intake, email_address: valid_email_address, tax_year: 2023)
        end

        it "finds the existing intake, signs it in, resets flags, and redirects to verification code" do
          expect(controller).to receive(:sign_in).with(instance_of(StateFileArchivedIntake)).and_call_original

          post :update, params: {email_address_form: {email_address: valid_email_address}}

          expect(assigns(:form)).to be_valid

          active = controller.current_state_file_archived_intake
          expect(active.id).to eq(archived_intake.id)
          expect(active.email_address).to eq(valid_email_address)

          expect(session[:ssn_verified]).to be(false)
          expect(session[:mailing_verified]).to be(false)
          expect(session[:code_verified]).to be(false)
          expect(session[:email_address]).to be_nil

          expect(response).to redirect_to(edit_verification_code_path)
        end

        it "matches email case-insensitively" do
          post :update, params: {email_address_form: {email_address: mixed_case_email_address}}

          expect(assigns(:form)).to be_valid

          active = controller.current_state_file_archived_intake
          expect(active.id).to eq(archived_intake.id)
          expect(active.email_address).to eq(valid_email_address)

          expect(response).to redirect_to(edit_verification_code_path)
        end
      end

      context "and an archived intake does not exist with the email address" do
        it "creates a new intake for the year, signs it in, resets flags, and redirects" do
          expect {
            post :update, params: {email_address_form: {email_address: valid_email_address}}
          }.to change { StateFileArchivedIntake.count }.by(1)

          expect(assigns(:form)).to be_valid

          active = controller.current_state_file_archived_intake
          expect(active.email_address).to eq(valid_email_address)
          expect(active.tax_year).to eq(2023)
          expect(active.hashed_ssn).to be_nil
          expect(active.full_address).to eq("")

          expect(session[:ssn_verified]).to be(false)
          expect(session[:mailing_verified]).to be(false)
          expect(session[:code_verified]).to be(false)
          expect(session[:email_address]).to be_nil

          expect(response).to redirect_to(edit_verification_code_path)
        end
      end
    end

    context "when the form is invalid" do
      it "renders the edit template" do
        post :update, params: {email_address_form: {email_address: invalid_email_address}}
        expect(assigns(:form)).not_to be_valid
        expect(response).to render_template(:edit)
      end
    end

    context "when year_selected is missing" do
      before { session[:year_selected] = nil }

      it "redirects to root (via BaseController) and does not create or sign in" do
        expect(controller).to receive(:redirect_to).with("/en").and_call_original

        expect {
          post :update, params: {email_address_form: {email_address: valid_email_address}}
        }.not_to change { StateFileArchivedIntake.count }

        expect(controller.current_state_file_archived_intake).to be_nil
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
