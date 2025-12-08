require "rails_helper"

RSpec.describe PagesController, type: :request do
  before do
    ENV["INTERCOM_APP_ID"] = "fake app_id"
  end
  describe "/" do
    it "returns a successful response" do
      get root_path
      expect(response).to be_ok
    end
  end
end
