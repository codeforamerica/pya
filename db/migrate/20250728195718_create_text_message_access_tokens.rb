class CreateTextMessageAccessTokens < ActiveRecord::Migration[8.0]
  def change
    create_table :text_message_access_tokens do |t|
      t.string :sms_phone_number, null: false
      t.string :token, null: false
      t.timestamps
    end

    add_index :text_message_access_tokens, :token
  end
end
