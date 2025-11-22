require "rails_helper"

RSpec.describe StateFileArchivedIntake, type: :model do
  describe "#increment_failed_attempts" do
    before do
      allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("production"))
    end
    include ActiveSupport::Testing::TimeHelpers

    let(:failed_attempts) { 1 }
    let(:last_failure_time) { Time.current }

    let!(:state_file_archived_intake) do
      create(
        :state_file_archived_intake,
        failed_attempts: failed_attempts,
        state_code: "AZ",
        last_failed_attempt_at: last_failure_time
      )
    end

    context "when the last failure was within 1 hour" do
      it "does not reset failed_attempts, increments to 2, locks, and updates last_failed_attempt_at" do
        travel_to Time.current do
          expect(state_file_archived_intake.failed_attempts).to eq 1
          expect(state_file_archived_intake.access_locked?).to eq false

          state_file_archived_intake.increment_failed_attempts
          state_file_archived_intake.reload

          expect(state_file_archived_intake.failed_attempts).to eq 2
          expect(state_file_archived_intake.access_locked?).to eq true
          expect(state_file_archived_intake.last_failed_attempt_at)
            .to be_within(1.second).of(Time.current)
        end
      end
    end

    context "when the last failure was more than 1 hour ago" do
      let(:last_failure_time) { 61.minutes.ago }

      it "resets failed_attempts before incrementing, does not lock, and updates last_failed_attempt_at" do
        travel_to Time.current do
          expect(state_file_archived_intake.failed_attempts).to eq 1
          expect(state_file_archived_intake.access_locked?).to eq false

          state_file_archived_intake.increment_failed_attempts
          state_file_archived_intake.reload

          expect(state_file_archived_intake.failed_attempts).to eq 1
          expect(state_file_archived_intake.access_locked?).to eq false
          expect(state_file_archived_intake.last_failed_attempt_at)
            .to be_within(1.second).of(Time.current)
        end
      end
    end
  end

  describe "#fetch_random_addresses" do
    let!(:state_file_archived_intake) { create(:state_file_archived_intake) }

    before do
      allow(Aws::S3::Client).to receive(:new).and_return(
        double("Aws::S3::Client", get_object: true)
      )
      allow(CSV).to receive(:read).and_return(["123 Fake St", "456 Imaginary Rd"])
    end

    context "when in production environment" do
      before { allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("production")) }
      context "when state_file_archived_intake has different mailing states" do
        it "uses the correct file key and for AZ" do
          state_file_archived_intake.update!(state_code: "AZ")

          allow(state_file_archived_intake).to receive(:download_file_from_s3).and_call_original

          expect(state_file_archived_intake).to receive(:download_file_from_s3).with(
            "pya-production-docs",
            "az_addresses.csv",
            Rails.root.join("tmp", "az_addresses.csv").to_s
          )

          state_file_archived_intake.send(:fetch_random_addresses)
        end

        it "uses the correct file key and bucket for NY" do
          state_file_archived_intake.update!(state_code: "NY")

          allow(state_file_archived_intake).to receive(:download_file_from_s3).and_call_original

          expect(state_file_archived_intake).to receive(:download_file_from_s3).with(
            "pya-production-docs",
            "ny_addresses.csv",
            Rails.root.join("tmp", "ny_addresses.csv").to_s
          )

          state_file_archived_intake.send(:fetch_random_addresses)
        end
      end
    end

    context "when in development environment" do
      before { allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("development")) }

      it "uses the correct local file path" do
        expect(CSV).to receive(:read).with(
          Rails.root.join("app", "lib", "challenge_addresses", "az_addresses.csv"),
          headers: false
        ).and_return(["123 Fake St", "456 Imaginary Rd"])

        state_file_archived_intake.send(:fetch_random_addresses)
      end
    end
  end

  describe "#populate_fake_addresses" do
    let(:state_file_archived_intake) { build(:state_file_archived_intake, hashed_ssn: nil) }

    context "when state_file_archived_intake hashed ssn is nil" do
      it "does not populate fake_address_1 and fake_address_2" do
        state_file_archived_intake.save

        expect(state_file_archived_intake.fake_address_1).to be_nil
        expect(state_file_archived_intake.fake_address_2).to be_nil
      end
    end
  end
end
