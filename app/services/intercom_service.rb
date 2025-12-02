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

  def self.client
    token = ENV["INTERCOM_ACCESS_TOKEN"]
    return nil if token.blank?

    @client ||= Intercom::Client.new(token: token)
  end

  def self.with_client
    intercom_client = client
    return unless intercom_client

    yield intercom_client
  end
end
