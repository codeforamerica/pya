# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

def find_or_create_state_file_archived_intake(attributes)
  finder_columns = [:tax_year, :email_address, :phone_number, :hashed_ssn, :state_code]
  finder_attributes = attributes.slice(*finder_columns)
  if finder_attributes.blank?
    raise "Seeder must provide at least one of (#{finder_columns.join(', ')}) when making an archived intake"
  end

  archived_intake = StateFileArchivedIntake.find_by(finder_attributes) || StateFileArchivedIntake.new(attributes)
  return archived_intake if archived_intake.persisted?

  archived_intake.submission_pdf.attach(
    io: File.open(Rails.root.join("spec", "fixtures", "files", "document_bundle.pdf")),
    filename: "document_bundle.pdf"
  )
  archived_intake.save!
end

unless Rails.env.production?
  find_or_create_state_file_archived_intake(
    email_address: "archivedaz@example.com",
    hashed_ssn: SsnHashingService.hash("555001234"),
    mailing_apartment: "Apt 2B",
    mailing_city: "Munchkinville",
    mailing_street: "123 Yellow Brick Rd",
    mailing_state: "AZ",
    mailing_zip: "85034",
    state_code: "AZ",
    tax_year: 2023
  )

  find_or_create_state_file_archived_intake(
    email_address: "archivedaz1@example.com",
    hashed_ssn: SsnHashingService.hash("555001235"),
    mailing_apartment: nil,
    mailing_city: "Munchkinville",
    mailing_street: "15 West Tower Blvd",
    mailing_state: "AZ",
    mailing_zip: "85035",
    state_code: "AZ",
    tax_year: 2023
  )

  find_or_create_state_file_archived_intake(
    email_address: "archivedaz2@example.com",
    hashed_ssn: SsnHashingService.hash("555001236"),
    mailing_apartment: "Bldg 5",
    mailing_city: "Munchkinville",
    mailing_street: "15 Maypole St",
    mailing_state: "AZ",
    mailing_zip: "85040",
    state_code: "AZ",
    tax_year: 2023
  )

  find_or_create_state_file_archived_intake(
    email_address: "archivedaz3@example.com",
    hashed_ssn: SsnHashingService.hash("555001237"),
    mailing_apartment: "Bldg A",
    mailing_city: "Thropp City",
    mailing_street: "5 Whispers Ln",
    mailing_state: "AZ",
    mailing_zip: "85001",
    state_code: "AZ",
    tax_year: 2023
  )

  find_or_create_state_file_archived_intake(
    email_address: "archivedaz4@example.com",
    hashed_ssn: SsnHashingService.hash("555001238"),
    mailing_apartment: "APT 2",
    mailing_city: "Winkie County",
    mailing_street: "22-1 Arjiki Centre",
    mailing_state: "AZ",
    mailing_zip: "85701",
    state_code: "AZ",
    tax_year: 2023
  )

  # NY StateFileArchivedIntakes (5)
  find_or_create_state_file_archived_intake(
    email_address: "archivedny@example.com",
    hashed_ssn: SsnHashingService.hash("555009876"),
    mailing_apartment: "Unit 3",
    mailing_city: "Emerald City",
    mailing_street: "555 Tower Ave",
    mailing_state: "NY",
    mailing_zip: "10001",
    state_code: "NY",
    tax_year: 2023
  )

  find_or_create_state_file_archived_intake(
    email_address: "archivedny1@example.com",
    hashed_ssn: SsnHashingService.hash("555009875"),
    mailing_apartment: "Unit 50A",
    mailing_city: "Emerald City",
    mailing_street: "120-12 Underground St",
    mailing_state: "NY",
    mailing_zip: "10006",
    state_code: "NY",
    tax_year: 2023
  )

  find_or_create_state_file_archived_intake(
    email_address: "archivedny2@example.com",
    hashed_ssn: SsnHashingService.hash("555009874"),
    mailing_apartment: "Bldg 5",
    mailing_city: "Shiz",
    mailing_street: "202 University Avenue",
    mailing_state: "NY",
    mailing_zip: "12208",
    state_code: "NY",
    tax_year: 2023
  )

  find_or_create_state_file_archived_intake(
    email_address: "archivedny3@example.com",
    hashed_ssn: SsnHashingService.hash("555009873"),
    mailing_apartment: nil,
    mailing_city: "Wittica",
    mailing_street: "9 Great Railway Rd",
    mailing_state: "NY",
    mailing_zip: "11355",
    state_code: "NY",
    tax_year: 2023
  )

  find_or_create_state_file_archived_intake(
    email_address: "archivedny4@example.com",
    hashed_ssn: SsnHashingService.hash("555009872"),
    mailing_apartment: "Apt 1501",
    mailing_city: "Frottica",
    mailing_street: "12 Purple Meadow Dr",
    mailing_state: "NY",
    mailing_zip: "11101",
    state_code: "NY",
    tax_year: 11101
  )

end
