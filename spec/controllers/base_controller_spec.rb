require 'rails_helper'

describe BaseController, type: :controller do
  let(:email_address) { 'test@example.com' }
  let!(:archived_intake) { create :state_file_archived_intake, email_address: email_address }
  before do
    session[:email_address] = email_address
  end

  describe '#current_request' do
    it 'finds the StateFileArchivedIntakeRequest by email address' do
      expect(controller.current_archived_intake).to eq(archived_intake)
    end

    it 'matches email case insensitively' do
      session[:email_address] = 'TeSt@ExAmPlE.cOm'
      # TODO: test logging here https://codeforamerica.atlassian.net/browse/FYST-2088
      expect(controller.current_archived_intake).to eq(archived_intake)
    end

    it 'creates a new StateFileArchivedIntake when an email does not exist' do
      # TODO: test logging here https://codeforamerica.atlassian.net/browse/FYST-2088

      session[:email_address] = "new_email@domain.com"

      expect {
        @new_archived_intake = controller.current_archived_intake
      }.to change { StateFileArchivedIntake.count }.by(1)

      expect(@new_archived_intake.email_address).to eq("new_email@domain.com")
    end
  end
end
