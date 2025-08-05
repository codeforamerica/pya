require "rails_helper"

RSpec.describe PagesController, type: :request do
  describe "/" do
    it "returns a successful response" do
      get root_path
      expect(response).to be_ok
    end
  end
end
