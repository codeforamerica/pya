module ApplicationHelper
  def link_to_spanish(additional_attributes = {})
    link_to_locale("es", "Español", additional_attributes)
  end

  def link_to_english(additional_attributes = {})
    link_to_locale("en", "English", additional_attributes)
  end

  def link_to_locale(locale, label, additional_attributes = {})
    link_to(label,
      {locale: locale, params: request.query_parameters},
      lang: locale,
      id: "locale_switcher_#{locale}",
      **additional_attributes).html_safe
  end
end
