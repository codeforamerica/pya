class TurnContactPreferenceIntoEnum < ActiveRecord::Migration[8.0]
  def change
    remove_column :state_file_archived_intakes, :contact_preference, :string
    add_column :state_file_archived_intakes, :contact_preference, :integer, default: 0, null: false
  end
end
