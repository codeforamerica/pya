require 'csv'

class MailingAddressValidationController < BaseController
  # before_action :is_intake_locked
  # before_action :confirm_code_and_ssn_verification
  def edit
    @addresses = current_archived_intake.address_challenge_set
    @form = MailingAddressValidationForm.new(addresses: @addresses, current_address: current_archived_intake.full_address)
  end

  def update
    @form = MailingAddressValidationForm.new(mailing_address_validation_form_params, addresses: @addresses, current_address: current_archived_intake.full_address)
    @addresses = current_archived_intake.address_challenge_set


    if @form.valid?
      session[:mailing_verified] = true

      redirect_to state_file_archived_intakes_pdfs_path
    elsif params["state_file_archived_intakes_mailing_address_validation_form"].present?
      current_archived_intake.update(permanently_locked_at: Time.now)
      redirect_to state_file_archived_intakes_verification_error_path
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
    params.fetch(:state_file_archived_intakes_mailing_address_validation_form, {}).permit(:selected_address)
  end
end
