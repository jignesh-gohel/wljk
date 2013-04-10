# Do not use a model named Mail in Rails.
# Reference: https://github.com/rails/rails/issues/5544
class BulkMailer < ActionMailer::Base
  #default from: Settings.bulk_mails.default.from

  def general_mail(mail_template)
    @mail_template = mail_template
    @content = @mail_template.content
    @recipients = @mail_template.recipients.collect { |recipient| recipient.email }
    @subject = @mail_template.subject
    @from = Settings.bulk_mails.default.from
    mail(from: @from, to: @recipients, subject: @subject)
  end

end