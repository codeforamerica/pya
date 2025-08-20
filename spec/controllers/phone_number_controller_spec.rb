require "rails_helper"

RSpec.describe PhoneNumberController, type: :controller do
  describe "GET #edit" do
    it "renders the edit template with a new PhoneNumberForm" do
      get :edit

      expect(assigns(:form)).to be_a(PhoneNumberForm)
      expect(response).to render_template(:edit)
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
        # TODO update this test with logging and the proper redirects https://codeforamerica.atlassian.net/browse/FYST-2088
        it "creates a request, updates the session and redirects to the root path" do
          post :update, params: {
            phone_number_form: {phone_number: valid_phone_number}
          }
          expect(assigns(:form)).to be_valid
          active_archived_intake = controller.send(:current_archived_intake)

          expect(active_archived_intake.phone_number).to eq(valid_phone_number)
          expect(active_archived_intake.hashed_ssn).to eq(archived_intake.hashed_ssn)
          expect(active_archived_intake.id).to eq(archived_intake.id)

          expect(session[:ssn_verified]).to be(false)
          expect(session[:mailing_verified]).to be(false)
          expect(session[:code_verified]).to be(false)
          expect(session[:phone_number]).to eq(valid_phone_number)

          expect(response).to redirect_to(edit_verification_code_path)
        end
      end

      context "and an archived intake does not exist with the phone number" do
        it "creates a new archived intake without a ssn or address, and redirects to the verification code page" do
          post :update, params: {
            phone_number_form: {phone_number: valid_phone_number}
          }
          expect(assigns(:form)).to be_valid

          active_archived_intake = controller.send(:current_archived_intake)
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

          expect(session[:phone_number]).to eq(valid_phone_number)
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
