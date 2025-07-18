class CreateStateFileArchivedIntakes < ActiveRecord::Migration[8.0]
  def change
    create_table :state_file_archived_intakes do |t|
      t.timestamps
      t.string :email_address
      t.string :phone_number
      t.string :fake_address_1
      t.string :fake_address_2
      t.string :hashed_ssn
      t.string :mailing_apartment
      t.string :mailing_city
      t.string :mailing_state
      t.string :mailing_street
      t.string :mailing_zip
      t.string :state_code
      t.integer :tax_year
      t.integer :string
      t.boolean :unsubscribed_from_email, default: false, null: false
    end
  end
end
