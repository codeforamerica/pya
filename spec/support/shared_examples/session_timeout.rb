# spec/support/shared_examples/authenticated_controller.rb
RSpec.shared_examples "an authenticated archived intake controller" do |http_method, action|
  include Devise::Test::ControllerHelpers

  let(:intake) { create(:state_file_archived_intake) }
  let(:timeout_in) { StateFileArchivedIntake.respond_to?(:timeout_in) ? StateFileArchivedIntake.timeout_in : Devise.timeout_in }

  let(:keys_to_clear) { %i[year_selected ssn_verified mailing_verified code_verified email_address phone_number] }

  before { sign_in intake }

  it "redirects to root and clears session when expired" do
    session[:year_selected] = 2024
    session[:ssn_verified] = true
    session[:mailing_verified] = true
    session[:code_verified] = true
    session[:email_address] = "test@example.com"
    session[:phone_number] = "+15555550000"

    warden_key = "warden.user.state_file_archived_intake.session"
    session[warden_key] ||= {}
    session[warden_key]["last_request_at"] = (Time.current - timeout_in - 5).to_i

    public_send(http_method, action, params: {locale: :en})

    expect(response).to redirect_to(root_path(locale: :en))
    keys_to_clear.each { |k| expect(session[k]).to be_nil }
    expect(session["warden.user.state_file_archived_intake.key"]).to be_nil
  end
end
