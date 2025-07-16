class PhoneNumberController < BaseController
  def edit
    @form = PhoneNumberForm.new
  end

  def update
    @form = PhoneNumberForm.new(phone_number_form_params)

    if @form.valid?
      session[:ssn_verified] = false
      session[:mailing_verified] = false
      session[:code_verified] = false
      session[:phone_number] = @form.phone_number
      current_archived_intake
      # TODO Add some kind of logging here

      redirect_to root_path
    else
      render :edit
    end
  end

  private

  def phone_number_form_params
    params.require(:phone_number_form).permit(:phone_number)
  end
end
