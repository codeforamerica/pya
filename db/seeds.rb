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
  check_required_attributes(attributes)

  finder_columns = [ :hashed_ssn, :state_code, :tax_year ]
  finder_attributes = attributes.slice(*finder_columns)
  archived_intake = StateFileArchivedIntake.find_by(finder_attributes) || StateFileArchivedIntake.new(attributes)
  return archived_intake if archived_intake.persisted?

  archived_intake.submission_pdf.attach(
    io: File.open(Rails.root.join("spec", "fixtures", "files", "document_bundle.pdf")),
    filename: "document_bundle.pdf"
  )
  archived_intake.save!
end

def check_required_attributes(attributes)
  required_columns = [ :hashed_ssn, :state_code, :contact_preference, :tax_year, :mailing_street, :mailing_city, :mailing_state, :mailing_zip ]
  finder_attributes = attributes.slice(*required_columns)

  if finder_attributes.blank?
    raise "Seeder must provide at least one of (#{finder_attributes.join(', ')}) when making an archived intake"
  end

  required_columns.each do |column|
    if finder_attributes[column].blank?
      raise "Seeder must provide #{column} when making an archived intake"
    end
  end

  if attributes[:email_address].blank? && attributes[:phone_number].blank?
    raise "Seeder must provide contact information (email/phone) when making an archived intake"
  end

  if attributes[:contact_preference] == "email" && attributes[:email_address].blank?
    raise "Seeder must provide email_address when making an archived intake with email contact preference"
  end

  if attributes[:contact_preference] == "text" && attributes[:phone_number].blank?
    raise "Seeder must provide phone_number when making an archived intake with text contact preference"
  end
end

def find_or_create_az_archived_intake(attributes)
  find_or_create_state_file_archived_intake(
    attributes.merge(
      state_code: "az",
      mailing_state: "AZ",
      fake_address_1: "685 West Cove St, Florence, AZ,  85132",
      fake_address_2: "52 Blue Hills Drive, Phoenix, AZ, 85003"
    )
  )
end

def find_or_create_ny_archived_intake(attributes)
  find_or_create_state_file_archived_intake(
    attributes.merge(
      state_code: "ny",
      mailing_state: "NY",
      fake_address_1: "1161 Rhinelander Ave, Bronx, NY, 10461",
      fake_address_2: "921 Washington Ave, Brooklyn, NY, 11225"
    )
  )
end

def find_or_create_md_archived_intake(attributes)
  find_or_create_state_file_archived_intake(
    attributes.merge(
      state_code: "md",
      mailing_state: "MD",
      fake_address_1: "212 S Market St, Frederick, MD, 21701-6527",
      fake_address_2: "2105 Harwood Rd, District Hts, MD, 20747-2428"
    )
  )
end

def find_or_create_id_archived_intake(attributes)
  find_or_create_state_file_archived_intake(
    attributes.merge(
      state_code: "id",
      mailing_state: "ID",
      fake_address_1: "11522 N Steeldust Ct, Rathdrum, ID, 83858-6714",
      fake_address_2: "12082 W Edna St, Boise, ID, 83713-3645"
    )
  )
end

def find_or_create_nc_archived_intake(attributes)
  find_or_create_state_file_archived_intake(
    attributes.merge(
      state_code: "nc",
      mailing_state: "NC",
      fake_address_1: "70 Willoughby Park Rd, King, NC, 27021",
      fake_address_2: "3 Lark Springs Dr, Sandy Ridge, NC, 27046"
    )
  )
end

def find_or_create_nj_archived_intake(attributes)
  find_or_create_state_file_archived_intake(
    attributes.merge(
      state_code: "nj",
      mailing_state: "NJ",
      fake_address_1: "6 Denver Lane, Camden, NJ, 08106",
      fake_address_2: "190 North Jefferson Street, Hackensack, NJ, 07604"
    )
  )
end

unless Rails.env.production?

  # 2023 and 2024 AZ Clients (same address, contact)
  az_repeat_data = [
    [ "Apt 2B", "Munchkinville", "123 Yellow Brick Rd", "85034" ],
    [ nil, "Munchkinville", "15 West Tower Blvd", "85035" ],
    [ nil, "Winkie County", "50 Feather Estates", "85033", true ]
  ]
  az_repeat_data.each_with_index do |data, i|
    changed_contact = data[4]
    find_or_create_az_archived_intake(
      email_address: "az#{i}@example.com",
      hashed_ssn: SsnHashingService.hash("55500#{i}234"),
      mailing_apartment: data[0],
      mailing_city: data[1],
      mailing_street: data[2],
      mailing_zip: data[3],
      contact_preference: "email",
      tax_year: 2023
    )
    find_or_create_az_archived_intake(
      email_address: changed_contact ? "az-changed#{i}@example.com" : "az#{i}@example.com", # email changed from last year
      phone_number: "+1480666000#{i}",
      hashed_ssn: SsnHashingService.hash("55500#{i}234"),
      mailing_apartment: data[0],
      mailing_city: data[1],
      mailing_street: data[2],
      mailing_zip: data[3],
      contact_preference: i % 2 == 0 ? "text" : "email", # changed from email 2023 -> text in 2024
      tax_year: 2024
    )
  end

  # 2023 Only AZ Clients
  az_2023_only_data = [
    [ "Bldg 5", "Munchkinville", "15 Maypole St", "85040" ],
    [ "Blythe Lab", "Thropp City", "5123 Blink St", "85003" ]
  ]
  az_2023_only_data.each_with_index do |data, i|
    find_or_create_az_archived_intake(
      email_address: "az2023#{i}@example.com",
      hashed_ssn: SsnHashingService.hash("555001#{i}34"),
      mailing_apartment: data[0],
      mailing_city: data[1],
      mailing_street: data[2],
      mailing_zip: data[3],
      contact_preference: "email",
      tax_year: 2023
    )
  end

  # 2024 Only AZ Clients
  find_or_create_az_archived_intake(
    email_address: "az-2024@example.com",
    phone_number: "+14805551133",
    hashed_ssn: SsnHashingService.hash("555001515"),
    mailing_apartment: "2G Apt",
    mailing_city: "Thropp City",
    mailing_street: "1 Bop Ave",
    mailing_zip: 85002,
    contact_preference: "text",
    tax_year: 2024
  )

  # 2023 Only NY Clients
  ny_2023_data = [
    [ nil, "Liverpool", "1 Liberty Ave", "13090" ],
    [ "APT 1", "Saratoga Springs", "20 Liberty Street", "12866" ],
    [ "Bldg A", "Brooklyn", "1 Liberty St", "11225" ],
    [ "Unit 2", "Bronx", "10 Libert Lane", "10461" ]
  ]
  ny_2023_data.each_with_index do |data, i|
    find_or_create_ny_archived_intake(
      email_address: "ny#{i}@example.com",
      hashed_ssn: SsnHashingService.hash("55500#{i}9876"),
      mailing_apartment: data[0],
      mailing_city: data[1],
      mailing_street: data[2],
      mailing_zip: data[3],
      contact_preference: "email",
      tax_year: 2023
    )
  end

  # 2024 Only MD Clients
  md_2024_data = [
      [ nil, "Rockville", "1 Crabb Ave", "20850" ],
      [ "APT 1", "Riva", "20 Fish Street", "21035" ],
      [ "Bldg A", "Bethesda", "1 Fish St", "20814" ],
      [ "Unit 2", "Brunswick", "10 Sea Lion Lane", "21716" ]
  ]
  md_2024_data.each_with_index do |data, i|
    find_or_create_md_archived_intake(
      email_address: "md#{i}@example.com",
      phone_number: "+1480666002#{i}",
      hashed_ssn: SsnHashingService.hash("55500298#{i}2"),
      mailing_apartment: data[0],
      mailing_city: data[1],
      mailing_street: data[2],
      mailing_zip: data[3],
      contact_preference: i % 2 == 0 ? "email" : "text",
      tax_year: 2024
    )
  end

  id_2024_data = [
    [ nil, "McCall", "1 Potato Ave", "83638" ],
    [ "APT 1", "Mackay", "20 Russet Street", "83251" ],
    [ "Bldg A", "Boise", "1 Potato Sack Way", "83638" ],
    [ "Unit 2", "Ammon", "10 Tater Tot Lane", "83406" ]
  ]
  id_2024_data.each_with_index do |data, i|
    find_or_create_id_archived_intake(
      email_address: "id#{i}@example.com",
      phone_number: "+1480666003#{i}",
      hashed_ssn: SsnHashingService.hash("55500298#{i}3"),
      mailing_apartment: data[0],
      mailing_city: data[1],
      mailing_street: data[2],
      mailing_zip: data[3],
      contact_preference: i % 2 == 0 ? "email" : "text",
      tax_year: 2024
    )
  end

  nc_2024_data = [
    [ nil, "Garner", "1 Mt Ridge Ave", "27529" ],
    [ "APT 1", "Durham", "20 Mountain Ct", "27710" ],
    [ "Bldg A", "Wilmington", "1 Smoky Mountain St", "28409" ],
    [ "Unit 2", "Cary", "7 Mountain Lane", "27511" ]
  ]
  nc_2024_data.each_with_index do |data, i|
    find_or_create_nc_archived_intake(
      email_address: "nc#{i}@example.com",
      phone_number: "+1480666004#{i}",
      hashed_ssn: SsnHashingService.hash("55500298#{i}4"),
      mailing_apartment: data[0],
      mailing_city: data[1],
      mailing_street: data[2],
      mailing_zip: data[3],
      contact_preference: i % 2 == 0 ? "email" : "text",
      tax_year: 2024
    )
  end

  nj_2024_data = [
    [ nil, "Adelphia", "324 Boardwalk St", "07710" ],
    [ "APT 1", "Atlantic City", "20 Boardwalk Street", "08404" ],
    [ "Bldg A", "Jersey City", "1 Boardwalk St", "07303" ],
    [ "Unit 2", "Mullica Hill", "10 Boardwalk Lane", "08062" ]
  ]
  nj_2024_data.each_with_index do |data, i|
    find_or_create_nj_archived_intake(
      email_address: "nj#{i}@example.com",
      phone_number: "+1480666005#{i}",
      hashed_ssn: SsnHashingService.hash("55500298#{i}5"),
      mailing_apartment: data[0],
      mailing_city: data[1],
      mailing_street: data[2],
      mailing_zip: data[3],
      contact_preference: i % 2 == 0 ? "email" : "text",
      tax_year: 2024
    )
  end
end
