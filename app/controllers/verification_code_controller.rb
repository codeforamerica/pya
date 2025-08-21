class VerificationCodeController < BaseController
  before_action :is_intake_locked
  before_action :setup_contact

  def setup_contact
    @contact_type = current_archived_intake.contact_preference
    @contact_info = current_archived_intake.contact
  end

  def edit
    @form = VerificationCodeForm.new(contact_info: @contact_info, contact_preference: current_archived_intake.contact_preference)
    case current_archived_intake.contact_preference
    when "text"
      @phone_number = current_archived_intake.phone_number
      TextMessageVerificationCodeJob.perform_later(
        phone_number: @phone_number,
        locale: I18n.locale
      )
    when "email"
      @email_address = current_archived_intake.email_address
      EmailVerificationCodeJob.perform_later(
        email_address: @email_address,
        locale: I18n.locale
      )
    else
      redirect_to root_path
    end
  end

  def update
    @form = VerificationCodeForm.new(verification_code_form_params, contact_info: current_archived_intake.contact, contact_preference: current_archived_intake.contact_preference)
    span = OpenTelemetry::Trace.current_span
    if @form.valid?
      span.add_event("Issued SSN challenge", attributes: {
        "state_file_archived_intake_id" => current_archived_intake.id
      })
      # standard:disable Style/IdenticalConditionalBranches
      case current_archived_intake.contact_preference
      when "text"
        # TODO: Some kind of logging here
      when "email"
        # TODO: Some kind of logging here
      end
      # standard:enable Style/IdenticalConditionalBranches
      current_archived_intake.reset_failed_attempts!
      session[:code_verified] = true
      redirect_to root_path
    else
      # standard:disable Style/IdenticalConditionalBranches
      case current_archived_intake.contact_preference
      when "text"
        # TODO: Some kind of logging here
      when "email"
        # TODO: Some kind of logging here
      end
      # standard:enable Style/IdenticalConditionalBranches
      current_archived_intake.increment_failed_attempts
      if current_archived_intake.access_locked?
        # TODO: Some kind of logging here
        redirect_to knock_out_path
        return
      end
      render :edit
    end
  end

  private

  def verification_code_form_params
    params.require(:verification_code_form).permit(:verification_code)
  end
end
