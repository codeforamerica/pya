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

ActiveRecord::Schema[8.0].define(version: 2025_07_25_192715) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "citext"
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "email_access_tokens", force: :cascade do |t|
    t.citext "email_address", null: false
    t.string "token", null: false
    t.string "token_type", default: "link"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_email_access_tokens_on_email_address"
    t.index ["token"], name: "index_email_access_tokens_on_token"
  end

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
    t.integer "contact_preference", default: 0, null: false
    t.integer "failed_attempts", default: 0, null: false
    t.datetime "locked_at"
    t.datetime "permanently_locked_at"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "state_file_archived_intake_access_logs", "state_file_archived_intakes", column: "state_file_archived_intakes_id"
end
