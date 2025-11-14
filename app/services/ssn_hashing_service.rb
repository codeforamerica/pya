class SsnHashingService
  def self.hash(ssn)
    OpenSSL::HMAC.hexdigest(
      "SHA256",
      "test_hashing_key_1234567890_abcdef_TEST_ONLY",
      "ssn|#{ssn}"
    )
  end
end
