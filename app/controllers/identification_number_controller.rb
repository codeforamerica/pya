class IdentificationNumberController < BaseController
  prepend_before_action :authenticate_state_file_archived_intake!
  before_action :confirm_code_verification
  before_action :is_intake_unavailable

  def edit
    @form = IdentificationNumberForm.new(archived_intake: current_state_file_archived_intake)
    render :edit
  end

  def update
    @form = IdentificationNumberForm.new(current_state_file_archived_intake, identification_number_form_params)

    if @form.valid?
      EventLogger.log("correct ssn challenge", current_state_file_archived_intake.id)
      current_state_file_archived_intake.reset_failed_attempts!
      session[:ssn_verified] = true
      EventLogger.log("issued mailing address challenge", current_state_file_archived_intake.id)
      redirect_to edit_mailing_address_validation_path
    else
      EventLogger.log("incorrect ssn challenge", current_state_file_archived_intake.id)
      current_state_file_archived_intake.increment_failed_attempts
      if current_state_file_archived_intake.access_locked?
        EventLogger.log("client lockout begin", current_state_file_archived_intake.id)
        redirect_to knock_out_path
        return
      end
      render :edit
    end
  end

  def identification_number_form_params
    params.expect(identification_number_form: [:ssn])
  end

  def confirm_code_verification
    unless session[:code_verified]
      EventLogger.log("unauthorized ssn attempt", current_state_file_archived_intake&.id)
      redirect_to root_path
    end
  end
end
