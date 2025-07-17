require "rails_helper"

describe ContactPreferenceController, type: :controller do

  describe '#edit' do
    render_views
    it 'succeeds' do
      get :edit
      expect(response).to be_successful
      expect(response.body).to have_text I18n.t("views.contact_preference.edit.title")
    end
  end
end
