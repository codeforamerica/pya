class MailingAddressValidationForm < Form
  attr_accessor :selected_address
  validates :selected_address, presence: true

  def initialize(attributes = {}, addresses: [], current_address: nil)
    super(attributes)
    @addresses = addresses
    @current_address = current_address
  end

  def valid?
    super
    selected_address == @current_address
  end
end
