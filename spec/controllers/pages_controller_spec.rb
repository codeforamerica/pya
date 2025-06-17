require "rails_helper"

RSpec.describe PagesController, type: :request  do
  describe "/" do
    it "returns a successful response" do
      get "/"
      expect(response).to be_ok
    end
  end
end
