# require "rails_helper"
#
# RSpec.describe IdentificationNumberController, type: :controller do
#   let(:intake_ssn) { "123456789" }
#   let(:invalid_ssn) { "212345678" }
#   let(:intake_request_email) { "ohhithere@gmail.com" }
#   let(:hashed_ssn) { SsnHashingService.hash(intake_ssn) }
#   let!(:archived_intake) { create(:state_file_archived_intake, hashed_ssn: hashed_ssn, email_address: intake_request_email, failed_attempts: 0) }
#
#   before do
#     session[:code_verified] = true
#     allow(controller).to receive(:current_archived_intake).and_return(archived_intake)
#     session[:email_address] = "ohhithere@example.com"
#     sign_in_archived_intake(archived_intake)
#
#     allow(EventLogger).to receive(:log)
#   end
#
#   describe "GET #edit" do
#     it_behaves_like "archived intake locked", action: :edit, method: :get
#     it_behaves_like "an authenticated archived intake controller", :get, :edit
#
#     it "renders the edit template with a new IdentificationNumberForm" do
#       get :edit
#
#       expect(assigns(:form)).to be_a(IdentificationNumberForm)
#       expect(response).to render_template(:edit)
#     end
#
#     it "redirects to root if code verification was not completed and logs unauthorized attempt" do
#       session[:code_verified] = nil
#
#       get :edit
#
#       expect(EventLogger).to have_received(:log).with("unauthorized ssn attempt", archived_intake.id)
#       expect(response).to redirect_to(root_path)
#     end
#   end
#
#   describe "PATCH #update" do
#     it_behaves_like "an authenticated archived intake controller", :patch, :update
#
#     context "with a valid ssn" do
#       it "redirects to the mailing address validation page and logs success + next challenge" do
#         expect(EventLogger).to receive(:log).with("correct ssn challenge", archived_intake.id).ordered
#         expect(EventLogger).to receive(:log).with("issued mailing address challenge", archived_intake.id).ordered
#
#         post :update, params: {
#           identification_number_form: {ssn: intake_ssn}
#         }
#
#         expect(assigns(:form)).to be_valid
#         expect(session[:ssn_verified]).to eq(true)
#         expect(archived_intake.reload.failed_attempts).to eq(0)
#         expect(response).to redirect_to(edit_mailing_address_validation_path)
#       end
#
#       it "resets failed attempts to zero even if one failed attempt has already been made" do
#         archived_intake.update!(failed_attempts: 1)
#
#         expect(EventLogger).to receive(:log).with("correct ssn challenge", archived_intake.id).ordered
#         expect(EventLogger).to receive(:log).with("issued mailing address challenge", archived_intake.id).ordered
#
#         post :update, params: {
#           identification_number_form: {ssn: intake_ssn}
#         }
#
#         expect(assigns(:form)).to be_valid
#         expect(archived_intake.reload.failed_attempts).to eq(0)
#       end
#     end
#
#     context "with an invalid ssn" do
#       it "increments failed_attempts, logs incorrect attempt, and re-renders edit on first failed attempt" do
#         expect(EventLogger).to receive(:log).with("incorrect ssn challenge", archived_intake.id)
#
#         post :update, params: {identification_number_form: {ssn: invalid_ssn}}
#
#         expect(archived_intake.reload.failed_attempts).to eq(1)
#         expect(response).to render_template(:edit)
#       end
#
#       it "locks the account, logs lockout begin, and redirects to knock out after multiple failed attempts" do
#         archived_intake.update!(failed_attempts: 1)
#
#         expect(EventLogger).to receive(:log).with("incorrect ssn challenge", archived_intake.id).ordered
#         expect(EventLogger).to receive(:log).with("client lockout begin", archived_intake.id).ordered
#
#         post :update, params: {identification_number_form: {ssn: invalid_ssn}}
#
#         expect(archived_intake.reload.failed_attempts).to eq(2)
#         expect(archived_intake.reload.access_locked?).to be_truthy
#         expect(response).to redirect_to(knock_out_path)
#       end
#     end
#   end
# end
