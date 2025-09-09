class BaseController < ApplicationController
  def find_or_create_state_file_archived_intake(phone_number: nil, email_address: nil)
    if session[:year_selected].blank?
      return redirect_to(root_path)
    end

    tax_year = session[:year_selected].to_i

    if phone_number.present?
      existing = StateFileArchivedIntake.find_by(phone_number: phone_number, tax_year: tax_year)
      intake = existing || StateFileArchivedIntake.create!(
        phone_number: phone_number,
        contact_preference: "text",
        tax_year: tax_year
      )
    elsif email_address.present?
      email = email_address.downcase
      existing = StateFileArchivedIntake.find_by("LOWER(email_address) = ? AND tax_year = ?", email, tax_year)
      intake = existing || StateFileArchivedIntake.create!(
        email_address: email,
        contact_preference: "email",
        tax_year: tax_year
      )
    else
      return redirect_to(root_path)
    end

    sign_in intake
  end

  def is_intake_unavailable
    if current_state_file_archived_intake.nil? || current_state_file_archived_intake.access_locked? || current_state_file_archived_intake.permanently_locked_at.present?
      redirect_to knock_out_path
    end
  end
end
