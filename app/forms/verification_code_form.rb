class VerificationCodeForm < Form
  attr_accessor :verification_code, :contact_info, :contact_preference

  validates :verification_code, presence: true
  def initialize(attributes = {}, contact_info: nil, contact_preference: nil)
    super(attributes)
    @contact_info = contact_info
    @contact_preference = contact_preference
  end

  def valid?
    return true if Rails.configuration.allow_magic_verification_code && verification_code == "000000"

    hashed_verification_code = VerificationCodeService.hash_verification_code_with_contact_info(@contact_info, verification_code)
    valid_code = case contact_preference
                 when "text"
                   TextMessageAccessToken.lookup(hashed_verification_code).exists?
                 when "email"
                   EmailAccessToken.lookup(hashed_verification_code).exists?
                 else
                   false
                 end

    errors.add(:verification_code, I18n.t("errors.attributes.verification_code.invalid")) unless valid_code
    binding.pry
    valid_code.present?
  end
end
