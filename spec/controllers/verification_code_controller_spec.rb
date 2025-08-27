require "rails_helper"

RSpec.describe VerificationCodeController, type: :controller do
  let(:email_address) { "test@example.com" }
  let!(:archived_intake) { create(:state_file_archived_intake, email_address: email_address, contact_preference: contact_preference, phone_number: phone_number) }
  let(:contact_preference) { "email" }
  let(:phone_number) { nil }
  let(:valid_verification_code) { "123456" }
  let(:invalid_verification_code) { "654321" }

  before do
    allow(controller).to receive(:current_archived_intake).and_return(archived_intake)
    allow(I18n).to receive(:locale).and_return(:en)
    sign_in_archived_intake(archived_intake)
  end

  describe "GET #edit" do
    it_behaves_like "archived intake locked", action: :edit, method: :get

    context "when the request is not locked" do
      before do
        allow(archived_intake).to receive(:access_locked?).and_return(false)
      end
      context "when contact preference is email" do
        let(:contact_preference) { "email" }
        it "renders the edit template with a new VerificationCodeForm and queues a job" do
          expect {
            get :edit
          }.to have_enqueued_job(EmailVerificationCodeJob).with(
            email_address: email_address,
            locale: :en
          )

          expect(assigns(:form)).to be_a(VerificationCodeForm)
          expect(assigns(:email_address)).to eq(email_address)
          expect(response).to render_template(:edit)
        end
      end

      context "when contact preference is text message" do
        let(:contact_preference) { "text" }
        let(:phone_number) { "5038675309" }
        it "renders the edit template with a new VerificationCodeForm and queues a job" do
          expect {
            get :edit
          }.to have_enqueued_job(TextMessageVerificationCodeJob).with(
            phone_number: phone_number,
            locale: :en
          )

          expect(assigns(:form)).to be_a(VerificationCodeForm)
          expect(assigns(:phone_number)).to eq(phone_number)
          expect(response).to render_template(:edit)
        end
      end
    end
  end

  describe "POST #update" do
    context "with a valid verification code" do
      before do
        allow_any_instance_of(VerificationCodeForm).to receive(:valid?).and_return(true)
      end

      it "does not increment failed_attempts" do
        post :update, params: {verification_code_form: {verification_code: valid_verification_code}}
        expect(session[:code_verified]).to eq(true)
        expect(archived_intake.failed_attempts).to eq(0)
        expect(response).to redirect_to(edit_identification_number_path)
      end
    end

    context "with an invalid verification code" do
      before do
        allow_any_instance_of(VerificationCodeForm).to receive(:valid?).and_return(false)
      end

      it "increments failed_attempts, and re-renders edit on first failed attempt" do
        post :update, params: {verification_code_form: {verification_code: invalid_verification_code}}
        expect(session[:code_verified]).to eq(nil)

        expect(archived_intake.reload.failed_attempts).to eq(1)
        expect(assigns(:form)).to be_a(VerificationCodeForm)
        expect(response).to render_template(:edit)
      end

      it "locks the account and redirects to root path after multiple failed attempts" do
        archived_intake.update!(failed_attempts: 1)
        post :update, params: {verification_code_form: {verification_code: invalid_verification_code}}

        expect(session[:code_verified]).to eq(nil)

        expect(archived_intake.reload.failed_attempts).to eq(2)
        expect(archived_intake.reload.access_locked?).to be_truthy
        expect(response).to redirect_to(knock_out_path)
      end
    end
  end
end
