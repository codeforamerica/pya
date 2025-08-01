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
FactoryBot.define do
  factory :email_access_token do
    email_address { "someone@example.com" }
    token { "randomly generated encrypted token" }
  end
end
