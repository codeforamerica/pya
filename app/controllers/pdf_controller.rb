class PdfController < BaseController
  before_action :is_intake_locked
  before_action :require_contact_preference
  before_action :require_archived_intake_email_code_verified
  before_action :require_archived_intake_ssn_verified
  before_action :require_mailing_address_verified

  before_action do
    if Rails.env.development? || Rails.env.test?
      ActiveStorage::Current.url_options = {protocol: request.protocol, host: request.host, port: request.port}
    end
  end

  def index
    @state = current_archived_intake.state_name
    @year = session[:year_selected]
    # create_state_file_access_log("issued_pdf_download_link")
  end

  def log_and_redirect
    # TODO Add logging here
    pdf_url = current_archived_intake.submission_pdf.url(expires_in: pdf_expiration_time, disposition: "inline")
    redirect_to pdf_url, allow_other_host: true
  end

  private

  def pdf_expiration_time
    if Rails.env.production?
      24.hours
    else
      10.minutes
    end
  end

  def require_contact_preference
    return if session[:email_address].present? || session[:phone_number].present?

    redirect_to knock_out_path
  end

  def require_archived_intake_email_code_verified
    return if session[:code_verified].present?

    redirect_to knock_out_path
  end

  def require_archived_intake_ssn_verified
    return if session[:ssn_verified].present?

    redirect_to knock_out_path
  end

  def require_mailing_address_verified
    return if session[:mailing_verified].present?

    redirect_to knock_out_path
  end
end
