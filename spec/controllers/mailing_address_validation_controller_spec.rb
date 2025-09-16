require "rails_helper"

RSpec.describe MailingAddressValidationController, type: :controller do
  include Devise::Test::ControllerHelpers

  let(:archived_intake) { create(:state_file_archived_intake, mailing_state: "NY") }
  let(:email_address) { "test@example.com" } # kept in case shared examples reference it
  let(:valid_code) { "123456" }
  let(:invalid_code) { "654321" }

  before do
    request.env["devise.mapping"] = Devise.mappings[:state_file_archived_intake]
    sign_in archived_intake

    session[:code_verified] = true
    session[:ssn_verified] = true

    allow(EventLogger).to receive(:log)
  end

  describe "GET #edit" do
    it_behaves_like "archived intake locked", action: :edit, method: :get
    it_behaves_like "an authenticated archived intake controller", :get, :edit

    context "when the request is locked" do
      before { allow(archived_intake).to receive(:access_locked?).and_return(true) }
    end

    context "when the request is not locked" do
      before { allow(archived_intake).to receive(:access_locked?).and_return(false) }

      it "renders the edit template with a new MailingAddressValidationForm" do
        get :edit
        expect(assigns(:form)).to be_a(MailingAddressValidationForm)
        expect(response).to render_template(:edit)
      end
    end

    it "redirects to root if code verification was not completed" do
      session[:code_verified] = nil
      session[:ssn_verified] = true

      get :edit

      expect(EventLogger).to have_received(:log).with("unauthorized mailing attempt", archived_intake.id)
      expect(response).to redirect_to(root_path)
    end

    it "redirects to root if ssn verification was not completed" do
      session[:code_verified] = true
      session[:ssn_verified] = nil

      get :edit

      expect(EventLogger).to have_received(:log).with("unauthorized mailing attempt", archived_intake.id)
      expect(response).to redirect_to(root_path)
    end
  end

  describe "PATCH #update" do
    it_behaves_like "an authenticated archived intake controller", :patch, :update

    context "with a valid chosen address" do
      it "logs success, sets mailing_verified, and redirects to pdf index path" do
        expect(EventLogger).to receive(:log).with("correct mailing address", archived_intake.id)

        post :update, params: {
          mailing_address_validation_form: {
            selected_address: archived_intake.full_address,
            addresses: archived_intake.address_challenge_set # ignored by strong params but fine to pass
          }
        }

        expect(assigns(:form)).to be_valid
        expect(session[:mailing_verified]).to eq(true)
        expect(response).to redirect_to(pdf_index_path)
      end
    end

    context "with an invalid chosen address" do
      it "logs incorrect attempt, permanently locks intake, and redirects to knock out" do
        expect(EventLogger).to receive(:log).with("incorrect mailing address", archived_intake.id)

        post :update, params: {
          mailing_address_validation_form: {
            selected_address: archived_intake.fake_address_1,
            addresses: archived_intake.address_challenge_set
          }
        }

        expect(assigns(:form)).not_to be_valid
        expect(session[:mailing_verified]).to be_nil
        expect(archived_intake.reload.permanently_locked_at).to be_present
        expect(response).to redirect_to(knock_out_path)
      end
    end

    context "without a chosen address" do
      it "re-renders the edit template" do
        post :update, params: {}

        expect(assigns(:form)).not_to be_valid
        expect(response).to render_template(:edit)
      end
    end
  end
end
