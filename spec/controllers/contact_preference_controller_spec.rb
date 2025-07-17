require "rails_helper"

describe ContactPreferenceController, type: :controller do
  render_views

  let(:archived_intake) { create(:state_file_archived_intake) }

  before do
    allow(controller).to receive(:current_archived_intake).and_return(archived_intake)
  end

  describe "#edit" do
    it "succeeds" do
      get :edit
      expect(response).to be_successful
      expect(response.body).to include I18n.t("views.contact_preference.edit.title")
    end
  end

  describe "#update" do
    context "when contact preference is email" do
      it "redirects to edit_email_address_path" do
        patch :update, params: {
          contact_preference_form: { contact_preference: "email" }
        }

        expect(response).to redirect_to(edit_email_address_path)
        expect(archived_intake.reload.contact_preference).to eq("email")
      end
    end

    context "when contact preference is text" do
      it "redirects to edit_phone_number_path" do
        patch :update, params: {
          contact_preference_form: { contact_preference: "text" }
        }

        expect(response).to redirect_to(edit_phone_number_path)
        expect(archived_intake.reload.contact_preference).to eq("text")
      end
    end

    context "when contact preference is unfilled" do
      it "renders :edit" do
        patch :update, params: {
          contact_preference_form: { contact_preference: "unfilled" }
        }

        expect(response).to render_template(:edit)
        expect(archived_intake.reload.contact_preference).to eq("unfilled")
      end
    end
  end
end
