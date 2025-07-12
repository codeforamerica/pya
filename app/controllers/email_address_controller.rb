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
        current_archived_intake
        #TODO Add some kind of logging here

        redirect_to root_path
      else
        render :edit
      end
    end

    private

    def email_address_form_params
      params.require(:email_address_form).permit(:email_address)
    end
end


