class IntercomService
  def self.generate_user_hash(user_id)
    secret = ENV["INTERCOM_SECURE_MODE_SECRET_KEY"]
    return nil if secret.blank? || user_id.blank?

    OpenSSL::HMAC.hexdigest(
      "sha256",
      secret,
      user_id.to_s
    )
  end
end
