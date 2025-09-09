require "rails_helper"

RSpec.describe PdfController, type: :controller do
  include Devise::Test::ControllerHelpers

  let(:email_address) { "test@example.com" }
  let!(:archived_intake) do
    create(:state_file_archived_intake,
      state_code: "NY",
      mailing_state: "NY",
      email_address: email_address)
  end
  let(:valid_verification_code) { "123456" }
  let(:invalid_verification_code) { "654321" }

  before do
    request.env["devise.mapping"] = Devise.mappings[:state_file_archived_intake]
    sign_in archived_intake

    session[:code_verified] = true
    session[:ssn_verified] = true
    session[:mailing_verified] = true
    session[:year_selected] = 2024

    allow(EventLogger).to receive(:log)
  end

  describe "GET #index" do
    it_behaves_like "archived intake locked", action: :index, method: :get
    it_behaves_like "an authenticated archived intake controller", :get, :index

    context "by default" do
      it "renders and sets @state/@year and logs 'issued pdf download link'" do
        expect(EventLogger).to receive(:log).with("issued pdf download link", archived_intake.id)

        get :index

        expect(assigns(:state)).to eq("New York")
        expect(assigns(:year)).to eq(2024)
        expect(response).to render_template(:index)
      end
    end
  end

  describe "POST #log_and_redirect" do
    let(:pdf_url) { "https://example.com/test.pdf" }
    let(:mock_pdf) { spy("pdf") }

    before do
      allow_any_instance_of(StateFileArchivedIntake)
        .to receive(:submission_pdf)
        .and_return(mock_pdf)
      allow(mock_pdf)
        .to receive(:url)
        .and_return(pdf_url)
    end

    it_behaves_like "an authenticated archived intake controller", :post, :log_and_redirect

    it "logs the access event and redirects to the provided pdf_url" do
      expect(EventLogger).to receive(:log).with("client pdf download click", archived_intake.id)

      post :log_and_redirect

      expect(response).to redirect_to(pdf_url)
    end
  end
end
