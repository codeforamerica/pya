# frozen_string_literal: true
require "rails_helper"

RSpec.describe 'Seeds' do
  context 'run seeder' do
    it 'succeeds' do
      Rails.application.load_seed
      expect(StateFileArchivedIntake.count).to eq 10
      expect(StateFileArchivedIntake.where(state_code: "az").count).to eq(5)
      expect(StateFileArchivedIntake.where(state_code: "ny").count).to eq(5)
    end
  end
end
