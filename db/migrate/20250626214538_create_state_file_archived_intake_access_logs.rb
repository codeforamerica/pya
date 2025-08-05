class CreateStateFileArchivedIntakeAccessLogs < ActiveRecord::Migration[8.0]
  def change
    create_table "state_file_archived_intake_access_logs" do |t|
      t.timestamps
      t.jsonb "details", default: "{}"
      t.integer "event_type"
      t.belongs_to "state_file_archived_intakes", foreign_key: true
    end
  end
end
