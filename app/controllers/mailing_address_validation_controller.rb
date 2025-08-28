class MailingAddressValidationController < BaseController
  prepend_before_action :authenticate_state_file_archived_intake!
  before_action :is_intake_unavailable
  before_action :confirm_code_and_ssn_verification

  def edit
    @addresses = current_archived_intake.address_challenge_set
    @year = current_archived_intake.tax_year
    @form = MailingAddressValidationForm.new(addresses: @addresses, current_address: current_archived_intake.full_address)
  end

  def update
    @addresses = current_archived_intake.address_challenge_set
    @form = MailingAddressValidationForm.new(mailing_address_validation_form_params, addresses: @addresses, current_address: current_archived_intake.full_address)
    if @form.valid?
      session[:mailing_verified] = true

      redirect_to pdf_index_path
    elsif params["mailing_address_validation_form"].present?
      current_archived_intake.update(permanently_locked_at: Time.now)
      redirect_to knock_out_path
    else
      render :edit
    end
  end

  private

  def confirm_code_and_ssn_verification
    unless session[:code_verified] && session[:ssn_verified]
      redirect_to root_path
    end
  end

  def mailing_address_validation_form_params
    return {} unless params[:mailing_address_validation_form]
    params.expect(mailing_address_validation_form: [:selected_address])
  end
end
