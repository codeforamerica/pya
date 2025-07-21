class PhoneNumberForm < Form
  attr_accessor :phone_number

  before_validation :normalize_phone_number

  validates :phone_number, e164_phone: true

  def normalize_phone_number
    self.phone_number = PhoneParser.normalize(phone_number) if phone_number.present?
  end
end
