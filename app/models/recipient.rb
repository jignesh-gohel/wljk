class Recipient < ActiveRecord::Base
  attr_accessible :email

  has_many :mail_recipients, dependent: :destroy
  has_many :mails, through: :mail_recipients

  def self.csv_to_emails_arr(recipients_str)
    return [] if recipients_str.empty?
    recipients_str.split(',').collect { |email| email.strip }
  end

  # Returns an array.
  # array.first returns an array of email addresses held by existing Recipient instance
  # array.last returns an array of new email addresses to be created as Recipients
  # in system
  def self.segregate_existing_and_new_recipients_from_str(recipients_str)
    return [] unless recipients_str.present?
    emails_arr = Recipient.csv_to_emails_arr(recipients_str)
    segregate_existing_and_new_recipients(emails_arr)
  end

  def self.segregate_existing_and_new_recipients(emails_arr)
    existing_recipients = Recipient.where(email: emails_arr)
    existing_recipients_email_arr = existing_recipients.collect { |recipient| recipient.email }
    new_recipients_email_arr = emails_arr - existing_recipients_email_arr
    [existing_recipients_email_arr, new_recipients_email_arr]
  end

end
