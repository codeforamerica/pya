class VerificationCodeMailer < ApplicationMailer
  def archived_intake_verification_code(to:, locale:, verification_code:)
    @locale = locale
    @service_name = "FileYourStateTaxes"
    @service_name_lower = "fileyourstatetaxes"
    @url = [Rails.configuration.statefile_url, locale].compact.join("/")
    @verification_code = verification_code
    attachments.inline['logo.png'] = File.read(Rails.root.join('app/assets/images/FYST_email_logo.png'))
    @subject = I18n.t("verification_code_mailer.archived_intake_verification_code.subject", service_name: @service_name, url: @url, locale: @locale)
    mail(to: to, subject: @subject, from: service.noreply_email, delivery_method_options: service.delivery_method_options)
  end
end
