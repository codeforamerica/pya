class SsnHashingService
  def self.hash(ssn)
    OpenSSL::HMAC.hexdigest(
      "SHA256",
      ENV["SSN_HASHING_KEY"],
      "ssn|#{ssn}"
    )
  end
end
