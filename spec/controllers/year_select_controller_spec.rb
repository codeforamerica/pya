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
      it "redirects to the 2023 path" do
        post :update, params: { year_select_form: { year: "2023" } }
        expect(response).to redirect_to(edit_email_address_path)
      end

      it "redirects to the 2024 path" do
        post :update, params: { year_select_form: { year: "2024" } }
        expect(response).to redirect_to(edit_email_address_path)
      end
    end

    context "with no year selected" do
      it "renders :show again" do
        post :update, params: { year_select_form: { year: nil } }
        expect(response).to render_template(:show)
      end
    end
  end
end
