require "rails_helper"

describe YearSelectController, type: :controller do
  describe "#show" do
    render_views

    it "responds successfully" do
      get :show
      expect(response).to be_successful
    end
  end

  describe "#update" do
    context "with a valid year" do
      it "redirects to the show email address path and saves the year to session" do
        post :update, params: {year_select_form: {year: "2023"}}
        expect(response).to redirect_to(edit_email_address_path)
        expect(session[:year_selected]).to eq("2023")
      end
    end

    context "with and invalid year" do
      it "renders :show again" do
        post :update, params: {year_select_form: {year: "2025"}}
        expect(response).to render_template(:show)
      end
    end

    context "with no year selected" do
      it "renders :show again" do
        post :update, params: {year_select_form: {year: nil}}
        expect(response).to render_template(:show)
      end
    end
  end
end
