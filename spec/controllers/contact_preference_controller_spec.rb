require "rails_helper"

describe ContactPreferenceController, type: :controller do
  render_views
  describe "#show" do
    it "succeeds" do
      get :show
      expect(response).to be_successful
      expect(response.body).to include I18n.t("views.contact_preference.edit.title")
    end
  end
end
