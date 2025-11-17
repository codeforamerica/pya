require "rails_helper"

RSpec.describe PhoneNumberController, type: :controller do
  include Devise::Test::ControllerHelpers

  before do
    request.env["devise.mapping"] = Devise.mappings[:state_file_archived_intake]
  end

  describe "GET #edit" do
    it "signs out any existing state_file_archived_intake and resets verification flags" do
      intake = create(:state_file_archived_intake)
      sign_in intake

      session[:ssn_verified] = true
      session[:mailing_verified] = true
      session[:code_verified] = true

      get :edit

      expect(controller.current_state_file_archived_intake).to be_nil

      expect(session[:ssn_verified]).to eq(false)
      expect(session[:mailing_verified]).to eq(false)
      expect(session[:code_verified]).to eq(false)

      expect(assigns(:form)).to be_a(PhoneNumberForm)
      expect(response).to render_template(:edit)
    end

    it "initializes a new PhoneNumberForm and sets verification flags to false when no one is signed in" do
      session[:ssn_verified] = true
      session[:mailing_verified] = nil
      session[:code_verified] = true

      get :edit

      expect(assigns(:form)).to be_a(PhoneNumberForm)
      expect(response).to render_template(:edit)

      expect(session[:ssn_verified]).to eq(false)
      expect(session[:mailing_verified]).to eq(false)
      expect(session[:code_verified]).to eq(false)
    end
  end

  describe "POST #update" do
    let(:valid_phone_number) { "+14153334444" }
    let(:invalid_phone_number) { "21122112" }

    context "when the form is valid" do
      before do
        session[:year_selected] = "2023"
      end
      context "and an archived intake exists with the phone number" do
        let!(:archived_intake) { create :state_file_archived_intake, phone_number: valid_phone_number, tax_year: "2023" }
        it "creates a request, updates the session, redirects to the verification code path and calls sign in with the existing intake" do
          expect(controller).to receive(:sign_in).with(instance_of(StateFileArchivedIntake)).and_call_original
          post :update, params: {
            phone_number_form: {phone_number: valid_phone_number}
          }
          expect(assigns(:form)).to be_valid
          active_archived_intake = controller.current_state_file_archived_intake

          expect(active_archived_intake.phone_number).to eq(valid_phone_number)
          expect(active_archived_intake.hashed_ssn).to eq(archived_intake.hashed_ssn)
          expect(active_archived_intake.id).to eq(archived_intake.id)

          expect(session[:ssn_verified]).to be(false)
          expect(session[:mailing_verified]).to be(false)
          expect(session[:code_verified]).to be(false)

          expect(response).to redirect_to(edit_verification_code_path)
        end
      end

      context "and an archived intake does not exist with the phone number" do
        it "creates a new archived intake without a ssn or address, and redirects to the verification code page and calls sign in with the existing intake" do
          expect(controller).to receive(:sign_in).with(instance_of(StateFileArchivedIntake)).and_call_original
          post :update, params: {
            phone_number_form: {phone_number: valid_phone_number}
          }
          expect(assigns(:form)).to be_valid

          active_archived_intake = controller.current_state_file_archived_intake
          expect(active_archived_intake.phone_number).to eq(valid_phone_number)
          expect(active_archived_intake.hashed_ssn).to eq(nil)
          expect(active_archived_intake.full_address).to eq("")
          expect(active_archived_intake.contact_preference).to eq("text")

          expect(response).to redirect_to(edit_verification_code_path)
        end

        it "resets verification session variables and sets phone number" do
          post :update, params: {
            phone_number_form: {phone_number: valid_phone_number}
          }

          expect(assigns(:form)).to be_valid

          expect(session[:ssn_verified]).to be(false)
          expect(session[:mailing_verified]).to be(false)
          expect(session[:code_verified]).to be(false)
        end
      end
    end

    context "when the form is invalid" do
      it "renders the edit template" do
        post :update, params: {
          phone_number_form: {phone_number: invalid_phone_number}
        }

        expect(assigns(:form)).not_to be_valid

        expect(response).to render_template(:edit)
      end
    end
  end
end
