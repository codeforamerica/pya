class ContactPreferenceForm < Form
  set_attributes_for :state_file_archived_intake, :contact_preference, :locale
  def save
    @archived_intake.update(attributes_for(:state_file_archived_intake))
  end
end