class CreateTextMessageAccessTokens < ActiveRecord::Migration[8.0]
  def change
    create_table :text_message_access_tokens do |t|
      t.string :sms_phone_number, null: false
      t.string :verification_code, null: false
      t.datetime :expires_at, null: false
      t.boolean :used, default: false
      t.timestamps
    end

    add_index :text_message_access_tokens, :sms_phone_number
    add_index :text_message_access_tokens, :expires_at
  end
end
