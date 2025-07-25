class VerificationCodeMailer < ApplicationMailer
  def archived_intake_verification_code(to:, locale:, verification_code:)
    @locale = locale
    @service_name = "FileYourStateTaxes"
    @service_name_lower = "fileyourstatetaxes"
    @url = [Rails.configuration.email_url, locale].compact.join("/")
    @verification_code = verification_code
    attachments.inline['logo.png'] = File.read(Rails.root.join('app/assets/images/FYST_email_logo.png'))
    @subject = I18n.t("mailers.archived_intake_verification_code.subject")
    delivery_method =       {
      api_key: ENV["MAILGUN_API_KEY"],
      domain: ENV["MAILGUN_DOMAIN"]
    }
    mail(to: to, subject: @subject, from: "hello@#mg.fileyourstatetaxes.org", delivery_method_options: delivery_method)
  end
end
