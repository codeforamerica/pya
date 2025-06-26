# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_06_26_214538) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "state_file_archived_intake_access_logs", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "details", default: "{}"
    t.integer "event_type"
    t.bigint "state_file_archived_intakes_id"
    t.index ["state_file_archived_intakes_id"], name: "idx_on_state_file_archived_intakes_id_e878049c06"
  end

  create_table "state_file_archived_intakes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email_address"
    t.string "phone_number"
    t.string "fake_address_1"
    t.string "fake_address_2"
    t.string "hashed_ssn"
    t.string "mailing_apartment"
    t.string "mailing_city"
    t.string "mailing_state"
    t.string "mailing_street"
    t.string "mailing_zip"
    t.string "state_code"
    t.integer "tax_year"
    t.boolean "unsubscribed_from_email", default: false, null: false
  end

  add_foreign_key "state_file_archived_intake_access_logs", "state_file_archived_intakes", column: "state_file_archived_intakes_id"
end
