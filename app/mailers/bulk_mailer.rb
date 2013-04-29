# Do not use a model named Mail in Rails.
# Reference: https://github.com/rails/rails/issues/5544
class BulkMailer < ActionMailer::Base

  #default from: Settings.bulk_mails.default.from

  def general_mail(mail_template_id)
    @mail_template = MailTemplate.find_by_id(mail_template_id)
    if @mail_template.nil?
      Sidekiq.logger.debug "No mail template found with id: #{mail_template_id}}"
      return
    end
    @content = @mail_template.content
    @recipients = @mail_template.recipients.collect { |recipient| recipient.email }
    @subject = @mail_template.subject
    @from = Settings.bulk_mails.default.from
    mail(from: @from, to: @recipients, subject: @subject)
  end

end