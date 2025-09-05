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

      find_or_create_state_file_archived_intake(phone_number: @form.phone_number)

      redirect_to edit_verification_code_path
    else
      render :edit
    end
  end

  private

  def phone_number_form_params
    params.expect(phone_number_form: [:phone_number])
  end
end
