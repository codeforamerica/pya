# frozen_string_literal: true
class CustomFailureApp < Devise::FailureApp
  def redirect_url
    case
    when locked_out?
      knock_out_path
    else
      super
    end
  end

  private

  def locked_out?
    warden_message == :locked
  end

  def locked_out_path
    Rails.application.routes.url_helpers.knock_out_path(locale: i18n_locale)
  end
end
