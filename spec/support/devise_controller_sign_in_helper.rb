module DeviseControllerSignInHelper
  def sign_in_archived_intake(intake)
    @request.env["devise.mapping"] = Devise.mappings[:state_file_archived_intake]
    sign_in(intake, scope: :state_file_archived_intake)
  end
end

RSpec.configure do |config|
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include DeviseControllerSignInHelper, type: :controller
end
