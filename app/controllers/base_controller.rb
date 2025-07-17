class BaseController < ApplicationController
    def current_archived_intake
      # If a user does not have an associated email, we still create an ArchivedIntake
      # so they can go through the flow. This prevents it from being obvious whether
      # an email is linked to an existing intake.
      #
      # These intakes are created without an IP address, meaning the user will not
      # be able to pass the identification number controller.
      return unless session[:email_address].present?

      email = session[:email_address].downcase
      existing = StateFileArchivedIntake.find_by("LOWER(email_address) = ?", email)
      existing || StateFileArchivedIntake.create(email_address: email)
    end

    def is_intake_locked
      if current_archived_intake.nil? || current_archived_intake.access_locked? || current_archived_intake.permanently_locked_at.present?
        redirect_to knock_out_path
      end
    end
end
