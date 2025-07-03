class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  around_action :switch_locale

  def self.default_url_options
    { locale: I18n.locale }.merge(super)
  end

  private

  def switch_locale(&action)
    I18n.with_locale(locale, &action)
  end

  def locale
    available_locale(params[:locale]) ||
      http_accept_language.compatible_language_from(I18n.available_locales) ||
      I18n.default_locale
  end

  def available_locale(locale)
    locale if I18n.available_locales.map(&:to_s).include?(locale.to_s)
  end
end
