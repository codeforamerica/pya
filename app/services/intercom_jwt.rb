require "jwt"

class IntercomJwt
  ALGORITHM = "HS256".freeze

  def self.for(intake)
    return nil unless intake

    payload = {
      user_id: intake.id.to_s,
      exp: 30.minutes.from_now.to_i
    }.compact

    secret = ENV["INTERCOM_SECURE_MODE_SECRET_KEY"]
    JWT.encode(payload, secret, ALGORITHM)
  end
end
