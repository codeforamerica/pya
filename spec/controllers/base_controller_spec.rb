require "rails_helper"

describe BaseController, type: :controller do
  let(:email_address) { "test@example.com" }
  let(:phone_number) { "4153334444" }

  let!(:email_intake) { create :state_file_archived_intake, email_address: email_address }
  let!(:phone_intake) { create :state_file_archived_intake, phone_number: phone_number }

  describe "#current_archived_intake" do
    context "when session has email_address" do
      before { session[:email_address] = email_address }

      it "finds the intake by email" do
        expect(controller.current_archived_intake).to eq(email_intake)
      end

      it "matches email case-insensitively" do
        session[:email_address] = "TeSt@ExAmPlE.cOm"
        expect(controller.current_archived_intake).to eq(email_intake)
      end

      it "creates a new intake if email does not exist" do
        session[:email_address] = "new_email@domain.com"

        expect {
          @new_intake = controller.current_archived_intake
        }.to change { StateFileArchivedIntake.count }.by(1)

        expect(@new_intake.email_address).to eq("new_email@domain.com")
        expect(@new_intake.phone_number).to be_nil
      end
    end

    context "when session has phone_number" do
      before { session[:phone_number] = phone_number }

      it "finds the intake by phone" do
        expect(controller.current_archived_intake).to eq(phone_intake)
      end

      it "creates a new intake if phone does not exist" do
        session[:phone_number] = "9998887777"

        expect {
          @new_intake = controller.current_archived_intake
        }.to change { StateFileArchivedIntake.count }.by(1)

        expect(@new_intake.phone_number).to eq("9998887777")
        expect(@new_intake.email_address).to be_nil
      end
    end

    context "when neither phone_number nor email_address is set" do
      it "returns nil" do
        expect(controller.current_archived_intake).to be_nil
      end
    end
  end

  describe "#is_intake_locked" do
    let!(:archived_intake) { create :state_file_archived_intake }
    before do
      allow(controller).to receive(:current_archived_intake).and_return(archived_intake)
    end

    context "when the request is nil" do
      before do
        allow(controller).to receive(:current_archived_intake).and_return(nil)
      end

      it "redirects to verification error page" do
        expect(controller).to receive(:redirect_to).with(knock_out_path)
        controller.is_intake_locked
      end
    end

    context "when the request is locked" do
      before do
        allow(archived_intake).to receive(:access_locked?).and_return(true)
      end

      it "redirects to verification error page" do
        expect(controller).to receive(:redirect_to).with(knock_out_path)
        controller.is_intake_locked
      end
    end

    context "when the archived intake is permanently locked" do
      before do
        allow(archived_intake).to receive(:permanently_locked_at).and_return(Time.current)
      end

      it "redirects to verification error page" do
        expect(controller).to receive(:redirect_to).with(knock_out_path)
        controller.is_intake_locked
      end
    end

    context "when the request is valid and not locked" do
      before do
        allow(archived_intake).to receive(:access_locked?).and_return(false)
        allow(archived_intake).to receive(:permanently_locked_at).and_return(nil)
      end

      it "does not redirect" do
        expect(controller).not_to receive(:redirect_to)
        controller.is_intake_locked
      end
    end
  end
end
