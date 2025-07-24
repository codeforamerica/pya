class AddDeviseToArchivedIntakes < ActiveRecord::Migration[8.0]
  def change
    add_column :state_file_archived_intakes, :failed_attempts, :integer, default: 0, null: false
    add_column :state_file_archived_intakes, :locked_at, :datetime
    add_column :state_file_archived_intakes, :permanently_locked_at, :datetime
  end
end
