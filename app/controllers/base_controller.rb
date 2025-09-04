class BaseController < ApplicationController

  def find_or_create_statefile_archived_intake
    tax_year = session[:year_selected].to_i
    if session[:phone_number].present?
      phone = session[:phone_number]
      existing = StateFileArchivedIntake.find_by(phone_number: phone, tax_year: tax_year)
      intake = existing || StateFileArchivedIntake.create(phone_number: phone, contact_preference: "text", tax_year: tax_year)
    elsif session[:email_address].present?
      email = session[:email_address].downcase
      existing = StateFileArchivedIntake.find_by("LOWER(email_address) = ? AND tax_year = ?", email, tax_year)
      intake = existing || StateFileArchivedIntake.create(email_address: email, contact_preference: "email", tax_year: tax_year)
    end
    sign_in intake
  end
  def current_archived_intake
    return current_state_file_archived_intake
    # If a user does not have an associated email or phone, we still create an ArchivedIntake
    # so they can go through the flow. This prevents it from being obvious whether
    # an email or phone is linked to an existing intake.
    #
    # These intakes are created without an IP address, meaning the user will not
    # be able to pass the identification number controller.
    # return nil if session[:year_selected].nil?
    tax_year = session[:year_selected].to_i

    # if session[:phone_number].present?
    #   phone = session[:phone_number]
    #   existing = StateFileArchivedIntake.find_by(phone_number: phone, tax_year: tax_year)
    #   existing || StateFileArchivedIntake.create(phone_number: phone, contact_preference: "text", tax_year: tax_year)
    # elsif session[:email_address].present?
    #   email = session[:email_address].downcase
    #   existing = StateFileArchivedIntake.find_by("LOWER(email_address) = ? AND tax_year = ?", email, tax_year)
    #   existing || StateFileArchivedIntake.create(email_address: email, contact_preference: "email", tax_year: tax_year)
    # end
  end

  def is_intake_unavailable
    if current_archived_intake.nil? || current_archived_intake.access_locked? || current_archived_intake.permanently_locked_at.present?
      redirect_to knock_out_path
    end
  end
end
