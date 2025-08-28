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

      intake = current_archived_intake
      sign_in intake

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
