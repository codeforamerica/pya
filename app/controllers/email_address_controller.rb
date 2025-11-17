class EmailAddressController < BaseController
  def edit
    sign_out(:state_file_archived_intake) if respond_to?(:sign_out)

    session[:ssn_verified] = false
    session[:mailing_verified] = false
    session[:code_verified] = false

    @form = EmailAddressForm.new
  end

  def update
    @form = EmailAddressForm.new(email_address_form_params)

    if @form.valid?
      session[:ssn_verified] = false
      session[:mailing_verified] = false
      session[:code_verified] = false

      create_and_login_state_file_archived_intake(email_address: @form.email_address)
      return if performed?

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
