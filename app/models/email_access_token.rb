# == Schema Information
#
# Table name: email_access_tokens
#
#  id            :bigint           not null, primary key
#  email_address :citext           not null
#  token         :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_email_access_tokens_on_email_address  (email_address)
#  index_email_access_tokens_on_token          (token)
#
class EmailAccessToken < ApplicationRecord
  validates_presence_of :token
  validates_presence_of :email_address
  validate :valid_email_address
  after_create :logging
  before_create :ensure_token_limit

  scope :lookup, ->(raw_token) do
    where(token: Devise.token_generator.digest(EmailAccessToken, :token, raw_token)).where("created_at > ?", Time.current - 10.minutes)
  end

  def self.generate!(email_address:, client_id: nil)
    raw_verification_code, hashed_verification_code = VerificationCodeService.generate(email_address)
    [ raw_verification_code, create!(
      email_address: email_address,
      token: Devise.token_generator.digest(self.class, :token, hashed_verification_code)
    ) ]
  end

  private

  def logging
    # TODO: Add logging here
  end

  def ensure_token_limit
    existing_token_count = self.class.where(email_address: email_address).count

    if existing_token_count > 4
      self.class.where(email_address: email_address).order(created_at: :asc).limit(existing_token_count - 4).delete_all
    end
  end

  def valid_email_address
    unless email_address.present? && ValidEmail2::Address.new(email_address.strip).valid?
      errors.add(:email_address, :invalid)
    end
  end
end
