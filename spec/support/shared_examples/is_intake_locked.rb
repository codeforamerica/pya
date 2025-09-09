RSpec.shared_examples "archived intake locked" do |action:, method: :get, params: {}|
  include Devise::Test::ControllerHelpers

  before do
    request.env["devise.mapping"] = Devise.mappings[:state_file_archived_intake]
    allow(controller).to receive(:knock_out_path).and_return("/knock_out")
  end

  context "when there is no archived intake" do
    before do
      if controller.respond_to?(:authenticate_state_file_archived_intake!)
        allow(controller).to receive(:authenticate_state_file_archived_intake!).and_return(true)
      end
      sign_out :state_file_archived_intake
    end

    it "redirects to verification error page" do
      public_send(method, action, params: params)
      expect(response).to redirect_to("/knock_out")
    end
  end

  context "when the archived intake is locked" do
    let!(:locked) { create(:state_file_archived_intake, locked_at: Time.zone.now) }

    before { sign_in locked }

    it "redirects to verification error page" do
      public_send(method, action, params: params)
      expect(response).to redirect_to("/en/knock_out")
    end
  end

  context "when the archived intake is permanently locked" do
    let!(:permanently_locked_intake) { create(:state_file_archived_intake, permanently_locked_at: Time.zone.now) }

    before { sign_in permanently_locked_intake }

    it "redirects to verification error page" do
      public_send(method, action, params: params)
      expect(response).to redirect_to("/knock_out")
    end
  end

  context "when the archived intake is valid and not locked" do
    let!(:intake) { create(:state_file_archived_intake) }

    before { sign_in intake }

    it "does not redirect" do
      public_send(method, action, params: params)
      expect(response).not_to be_redirect
    end
  end
end
