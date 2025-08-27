# == Schema Information
#
# Table name: state_file_archived_intakes
#
#  id                      :bigint           not null, primary key
#  contact_preference      :integer          default("unfilled"), not null
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
  devise :lockable, unlock_in: 60.minutes, unlock_strategy: :time
  devise :timeoutable, timeout_in: 1.minutes
  include StateNames

  enum :contact_preference, {unfilled: 0, email: 1, text: 2}, prefix: :contact_preference

  def full_address
    address_parts = [mailing_street, mailing_apartment, mailing_city, mailing_state, mailing_zip]
    address_parts.compact_blank.join(", ")
  end

  def self.maximum_attempts
    2
  end

  def increment_failed_attempts
    super
    lock_access! if attempts_exceeded? && !access_locked?
  end

  def contact
    (contact_preference == "text") ? phone_number : email_address
  end

  def fake_addresses
    [fake_address_1, fake_address_2]
  end

  def address_challenge_set
    fake_addresses.push(full_address).shuffle
  end

  def state_name
    state_full_name(state_code)
  end

  private

  # this is here because we don't want people to get new fake addresses if they refresh the page or return with a new session
  def populate_fake_addresses
    self.fake_address_1, self.fake_address_2 = fetch_random_addresses
  end

  def fetch_random_addresses
    if hashed_ssn.present?
      file_key = "#{state_code.downcase}_addresses.csv"
      if Rails.env.development? || Rails.env.test?
        file_path = Rails.root.join("app", "lib", "challenge_addresses", file_key)
      else
        bucket = select_bucket

        file_key = "#{state_code.downcase}_addresses.csv"

        file_path = File.join(Rails.root, "tmp", File.basename(file_key))

        download_file_from_s3(bucket, file_key, file_path) unless File.exist?(file_path)
      end
      addresses = CSV.read(file_path, headers: false).flatten
      addresses.sample(2)
    end
  end

  def download_file_from_s3(bucket, file_key, file_path)
    s3_client = Aws::S3::Client.new
    s3_client.get_object(
      response_target: file_path,
      bucket: bucket,
      key: file_key
    )
  end

  # TODO: https://codeforamerica.atlassian.net/browse/FYST-2232 change this to look at prod s3 bucket
  # standard:disable Style/IdenticalConditionalBranches
  def select_bucket
    case Rails.env
    when "development"
      "pya-staging-docs"
    when "production"
      "pya-staging-docs"
    else
      "pya-staging-docs"
    end
  end
  # standard:enable Style/IdenticalConditionalBranches
end
