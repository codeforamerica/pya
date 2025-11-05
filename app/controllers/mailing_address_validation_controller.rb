class MailingAddressValidationController < BaseController
  prepend_before_action :authenticate_state_file_archived_intake!
  before_action :is_intake_unavailable
  before_action :confirm_code_and_ssn_verification

  def edit
    @addresses = current_state_file_archived_intake.address_challenge_set
    @form = MailingAddressValidationForm.new(addresses: @addresses, current_address: current_state_file_archived_intake.full_address, tax_year: current_state_file_archived_intake.tax_year )
  end

  def update
    @year = current_state_file_archived_intake.tax_year
    @addresses = current_state_file_archived_intake.address_challenge_set
    @form = MailingAddressValidationForm.new(mailing_address_validation_form_params, addresses: @addresses, current_address: current_state_file_archived_intake.full_address, tax_year: current_state_file_archived_intake.tax_year)
    if @form.valid?
      EventLogger.log("correct mailing address", current_state_file_archived_intake.id)
      session[:mailing_verified] = true

      redirect_to pdf_index_path
    elsif params["mailing_address_validation_form"].present?
      EventLogger.log("incorrect mailing address", current_state_file_archived_intake.id)
      current_state_file_archived_intake.update(permanently_locked_at: Time.now)
      redirect_to knock_out_path
    else
      render :edit
    end
  end

  private

  def confirm_code_and_ssn_verification
    unless session[:code_verified] && session[:ssn_verified]
      EventLogger.log("unauthorized mailing attempt", current_state_file_archived_intake&.id)
      redirect_to root_path
    end
  end

  def mailing_address_validation_form_params
    return {} unless params[:mailing_address_validation_form]
    params.expect(mailing_address_validation_form: [:selected_address])
  end
end
