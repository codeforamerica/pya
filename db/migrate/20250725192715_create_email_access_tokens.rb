class CreateEmailAccessTokens < ActiveRecord::Migration[8.0]
  def change
    enable_extension "citext" unless extension_enabled?("citext")

    create_table :email_access_tokens do |t|
      t.citext :email_address, null: false
      t.string :token, null: false
      t.string :token_type, default: "link"

      t.timestamps
    end

    add_index :email_access_tokens, :token
    add_index :email_access_tokens, :email_address
  end
end
