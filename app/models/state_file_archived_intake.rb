# == Schema Information
#
# Table name: state_file_archived_intakes
#
#  id                      :bigint           not null, primary key
#  contact_preference      :integer          default(0), not null
#  email_address           :string
#  failed_attempts         :integer          default(0), not null
#  fake_address_1          :string
#  fake_address_2          :string
#  hashed_ssn              :string
#  locked_at               :datetime
#  mailing_apartment       :string
#  mailing_city            :string
#  mailing_state           :string
#  mailing_street          :string
#  mailing_zip             :string
#  permanently_locked_at   :datetime
#  phone_number            :string
#  state_code              :string
#  tax_year                :integer
#  unsubscribed_from_email :boolean          default(FALSE), not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#
class StateFileArchivedIntake < ApplicationRecord
  has_one_attached :submission_pdf
  has_many :state_file_archived_intake_access_logs, class_name: "StateFileArchivedIntakeAccessLog"

  enum :contact_preference, { unfilled: 0, email: 1, text: 2 }, prefix: :contact_preference

  def full_address
    address_parts = [ mailing_street, mailing_apartment, mailing_city, mailing_state, mailing_zip ]
    address_parts.compact_blank.join(", ")
  end
end
