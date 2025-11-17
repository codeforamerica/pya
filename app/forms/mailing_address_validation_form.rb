class MailingAddressValidationForm < Form
  attr_accessor :selected_address, :tax_year

  validates :selected_address,
            presence: {
              message: ->(object, data) {
                I18n.t(
                  "errors.attributes.selected_address.blank",
                  tax_year: object.tax_year
                )
              }
            }

  def initialize(attributes = {}, addresses: [], current_address: nil, tax_year:)
    super(attributes)
    @tax_year = tax_year
    @addresses = addresses
    @current_address = current_address
  end

  def valid?
    super
    selected_address == @current_address
  end
end
