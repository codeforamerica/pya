class ContactPreferenceController < BaseController
  def edit
    @form = ContactPreferenceForm.new(state_file_archived_intake: current_archived_intake)
  end

  def update
    @form = ContactPreferenceForm.new(contact_preference_form_params.merge(state_file_archived_intake: current_archived_intake))
    @form.save

    redirect_to root_path
  end

  private
  def contact_preference_form_params
    params.require(:contact_preference_form).permit(:contact_preference)
  end
end