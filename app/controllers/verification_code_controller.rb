class VerificationCodeController < BaseController
  prepend_before_action :log_stuff
  prepend_before_action :authenticate_state_file_archived_intake!
  before_action :is_intake_unavailable
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
      EventLogger.log("issued text challenge", current_archived_intake.id)
      TextMessageVerificationCodeJob.perform_later(
        phone_number: @phone_number,
        locale: I18n.locale
      )
    when "email"
      @email_address = current_archived_intake.email_address
      EventLogger.log("issued email challenge", current_archived_intake.id)
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
    if @form.valid?
      case current_archived_intake.contact_preference
      when "text"
        EventLogger.log("correct text challenge", current_archived_intake.id)
      when "email"
        EventLogger.log("correct email code", current_archived_intake.id)
      end
      current_archived_intake.reset_failed_attempts!
      session[:code_verified] = true
      EventLogger.log("issued ssn challenge", current_archived_intake.id)
      redirect_to edit_identification_number_path
    else
      case current_archived_intake.contact_preference
      when "text"
        EventLogger.log("incorrect text code", current_archived_intake.id)
      when "email"
        EventLogger.log("incorrect email code", current_archived_intake.id)
      end
      current_archived_intake.increment_failed_attempts
      if current_archived_intake.access_locked?
        EventLogger.log("client lockout begin", current_archived_intake.id)
        redirect_to knock_out_path
        return
      end
      render :edit
    end
  end

  private

  def log_stuff
    after_log = session.inspect
    intake_id = current_archived_intake.id
    Rails.logger.info(
      when: "on verification code page :(",
      session: after_log,
      intake_id: intake_id
    )
  end
  def verification_code_form_params
    params.expect(verification_code_form: [:verification_code])
  end
end
