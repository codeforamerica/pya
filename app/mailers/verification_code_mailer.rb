class VerificationCodeMailer < ApplicationMailer
  def archived_intake_verification_code(to:, locale:, verification_code:)
    @locale = locale
    @service_name = "FileYourStateTaxes"
    @service_name_lower = "fileyourstatetaxes"
    @url = [Rails.configuration.email_url, locale].compact.join("/")
    @verification_code = verification_code
    attachments.inline["logo.png"] = File.read(Rails.root.join("app/assets/images/FYST_email_logo.png"))
    @subject = I18n.t("mailers.archived_intake_verification_code.subject")
    domain = ENV["MAILGUN_DOMAIN"] || "localhost"
    @from = "hello@#{domain}"
    mail(
      to: to,
      subject: @subject,
      from: @from,
      delivery_method: :mailgun,
      delivery_method_options: {
        api_key: ENV["MAILGUN_API_KEY"],
        domain: ENV["MAILGUN_DOMAIN"]
      }
    )
  end
end
