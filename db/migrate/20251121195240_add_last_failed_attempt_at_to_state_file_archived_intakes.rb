class AddLastFailedAttemptAtToStateFileArchivedIntakes < ActiveRecord::Migration[8.0]
  def change
    add_column :state_file_archived_intakes, :last_failed_attempt_at, :datetime
  end
end
