require "rails_helper"

RSpec.describe VerificationCodeController, type: :controller do
  include Devise::Test::ControllerHelpers
  include ActiveJob::TestHelper

  let(:email_address) { "test@example.com" }
  let(:contact_preference) { "email" }
  let(:phone_number) { nil }
  let!(:archived_intake) do
    create(:state_file_archived_intake,
      email_address: email_address,
      contact_preference: contact_preference,
      phone_number: phone_number)
  end

  let(:valid_verification_code) { "123456" }
  let(:invalid_verification_code) { "654321" }

  before do
    request.env["devise.mapping"] = Devise.mappings[:state_file_archived_intake]
    sign_in archived_intake

    allow(EventLogger).to receive(:log)
  end

  describe "GET #edit" do
    it_behaves_like "archived intake locked", action: :edit, method: :get
    it_behaves_like "an authenticated archived intake controller", :get, :edit

    context "when the request is not locked" do
      before { allow(archived_intake).to receive(:access_locked?).and_return(false) }

      context "when contact preference is email" do
        let(:contact_preference) { "email" }

        it "renders :edit with a VerificationCodeForm and enqueues EmailVerificationCodeJob" do
          expect(EventLogger).to receive(:log).with("issued email challenge", archived_intake.id)

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

        it "renders :edit with a VerificationCodeForm and enqueues TextMessageVerificationCodeJob" do
          expect(EventLogger).to receive(:log).with("issued text challenge", archived_intake.id)

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
    it_behaves_like "an authenticated archived intake controller", :post, :update

    context "with a valid verification code" do
      before do
        allow_any_instance_of(VerificationCodeForm).to receive(:valid?).and_return(true)
      end

      context "email preference" do
        let(:contact_preference) { "email" }

        it "does not increment failed_attempts, logs success, issues ssn challenge, and redirects" do
          expect(EventLogger).to receive(:log).with("correct email code", archived_intake.id).ordered
          expect(EventLogger).to receive(:log).with("issued ssn challenge", archived_intake.id).ordered

          post :update, params: {verification_code_form: {verification_code: valid_verification_code}}

          expect(session[:code_verified]).to eq(true)
          expect(archived_intake.reload.failed_attempts).to eq(0)
          expect(response).to redirect_to(edit_identification_number_path)
        end
      end

      context "text preference" do
        let(:contact_preference) { "text" }
        let(:phone_number) { "5038675309" }

        it "does not increment failed_attempts, logs success, issues ssn challenge, and redirects" do
          expect(EventLogger).to receive(:log).with("correct text challenge", archived_intake.id).ordered
          expect(EventLogger).to receive(:log).with("issued ssn challenge", archived_intake.id).ordered

          post :update, params: {verification_code_form: {verification_code: valid_verification_code}}

          expect(session[:code_verified]).to eq(true)
          expect(archived_intake.reload.failed_attempts).to eq(0)
          expect(response).to redirect_to(edit_identification_number_path)
        end
      end
    end

    context "with an invalid verification code" do
      before do
        allow_any_instance_of(VerificationCodeForm).to receive(:valid?).and_return(false)
      end

      context "email preference" do
        let(:contact_preference) { "email" }

        it "increments failed_attempts and re-renders edit on first failed attempt" do
          expect(EventLogger).to receive(:log).with("incorrect email code", archived_intake.id)

          post :update, params: {verification_code_form: {verification_code: invalid_verification_code}}

          expect(session[:code_verified]).to be_nil
          expect(archived_intake.reload.failed_attempts).to eq(1)
          expect(assigns(:form)).to be_a(VerificationCodeForm)
          expect(response).to render_template(:edit)
        end

        context "with a recent failed attempt" do
          let!(:archived_intake) do
            create(
              :state_file_archived_intake,
              :with_recent_failed_attempt,
              email_address: email_address,
              contact_preference: "email"
            )
          end
          it "locks the account, logs lockout begin, and redirects after another attempt" do
            expect(EventLogger).to receive(:log).with("incorrect email code", archived_intake.id).ordered
            expect(EventLogger).to receive(:log).with("client lockout begin", archived_intake.id).ordered

            post :update, params: {verification_code_form: {verification_code: invalid_verification_code}}

            expect(session[:code_verified]).to be_nil
            expect(archived_intake.reload.failed_attempts).to eq(2)
            expect(archived_intake.reload.access_locked?).to be(true)
            expect(response).to redirect_to(knock_out_path)
          end
        end
      end

      context "text preference" do
        let(:contact_preference) { "text" }
        let(:phone_number) { "5038675309" }

        it "increments failed_attempts and re-renders edit on first failed attempt" do
          expect(EventLogger).to receive(:log).with("incorrect text code", archived_intake.id)

          post :update, params: {verification_code_form: {verification_code: invalid_verification_code}}

          expect(session[:code_verified]).to be_nil
          expect(archived_intake.reload.failed_attempts).to eq(1)
          expect(assigns(:form)).to be_a(VerificationCodeForm)
          expect(response).to render_template(:edit)
        end
        context "with a recent failed attempt" do
          let!(:archived_intake) do
            create(
              :state_file_archived_intake,
              :with_recent_failed_attempt,
              phone_number: phone_number,
              contact_preference: "text"
            )
          end
          it "locks the account, logs lockout begin, and redirects after multiple failed attempts" do
            expect(EventLogger).to receive(:log).with("incorrect text code", archived_intake.id).ordered
            expect(EventLogger).to receive(:log).with("client lockout begin", archived_intake.id).ordered

            post :update, params: {verification_code_form: {verification_code: invalid_verification_code}}

            expect(session[:code_verified]).to be_nil
            expect(archived_intake.reload.failed_attempts).to eq(2)
            expect(archived_intake.reload.access_locked?).to be(true)
            expect(response).to redirect_to(knock_out_path)
          end
        end
      end
    end
  end
end
