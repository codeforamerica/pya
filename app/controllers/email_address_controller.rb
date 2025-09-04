class EmailAddressController < BaseController
  def edit
    @form = EmailAddressForm.new
  end

  def update
    @form = EmailAddressForm.new(email_address_form_params)

    if @form.valid?
      session[:ssn_verified] = false
      session[:mailing_verified] = false
      session[:code_verified] = false
      session[:email_address] = @form.email_address
      session[:phone_number] = nil

      find_or_create_statefile_archived_intake
      # to_log = session.inspect
      # Rails.logger.info(
      #   when: "before sign in",
      #   session: to_log
      # )
      # sign_in current_archived_intake
      #
      # after_log = session.inspect
      # intake_id = current_archived_intake.id
      # Rails.logger.info(
      #   when: "after sign in",
      #   session: after_log,
      #   intake_id: intake_id
      # )
      redirect_to edit_verification_code_path
    else
      render :edit
    end
  end

  private

  def email_address_form_params
    params.expect(email_address_form: [:email_address])
  end
end
