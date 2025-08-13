class EmailAddressForm < Form
  attr_accessor :email_address

  before_validation { self.email_address = email_address.squish }

  validates :email_address, presence: true, "valid_email_2/email": true
end
