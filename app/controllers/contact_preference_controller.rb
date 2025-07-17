class ContactPreferenceController < BaseController
  def edit
    @form = ContactPreferenceForm.new(state_file_archived_intake: current_archived_intake)
  end

  def update
    @form = ContactPreferenceForm.new(contact_preference_form_params.merge(state_file_archived_intake: current_archived_intake))
    @form.save

    case @form.state_file_archived_intake.contact_preference
    when "email"
      redirect_to edit_email_address_path
    when "text"
      redirect_to edit_phone_number_path
    else
      render :edit
    end

  end

  private
  def contact_preference_form_params
    params.require(:contact_preference_form).permit(:contact_preference)
  end
end