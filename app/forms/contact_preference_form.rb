class ContactPreferenceForm < Form
  attr_accessor :state_file_archived_intake

  set_attributes_for :state_file_archived_intake, :contact_preference

  validates :email_address, presence: true
end