class EmailAddressController < BaseController
  def edit
    @form = SmsContactForm.new
  end

  def update
    @form = SmsContactForm.new(sms_contact_form_params)

    if @form.valid?
      session[:ssn_verified] = false
      session[:mailing_verified] = false
      session[:code_verified] = false
      session[:sms_contact] = @form.sms_contact
      current_archived_intake
      # TODO Add some kind of logging here

      redirect_to root_path
    else
      render :edit
    end
  end

  private

  def sms_contact_form_params
    params.require(:sms_contact_form).permit(:sms_contact)
  end
end
