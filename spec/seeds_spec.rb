# frozen_string_literal: true

require "rails_helper"

RSpec.describe 'Seeds' do
  context 'run seeder' do
    before(:each) do
      stub_const("ENV", "REVIEW_APP" => "true", "SSN_HASHING_KEY" => "hashing-key-test")
    end

    it 'succeeds' do
      Rails.application.load_seed
      expect(StateFileArchivedIntake.count).to eq 29
      expect(StateFileArchivedIntake.where(state_code: "az").count).to eq(9)
      expect(StateFileArchivedIntake.where(state_code: "ny").count).to eq(4)
      expect(StateFileArchivedIntake.where(state_code: "nc").count).to eq(4)
      expect(StateFileArchivedIntake.where(state_code: "id").count).to eq(4)
      expect(StateFileArchivedIntake.where(state_code: "md").count).to eq(4)
      expect(StateFileArchivedIntake.where(state_code: "nj").count).to eq(4)
    end
  end
end
