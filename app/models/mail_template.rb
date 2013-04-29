class MailTemplate < ActiveRecord::Base
  attr_accessible :content, :user_id, :subject

  has_many :mail_recipients, dependent: :destroy
  has_many :recipients, through: :mail_recipients
  has_many :schedule_occurrences, dependent: :destroy, foreign_key: 'scheduled_entity_id'
  has_one :mail_schedule, dependent: :destroy


  accepts_nested_attributes_for :recipients, :mail_recipients
  attr_accessible :recipients_attributes

  accepts_nested_attributes_for :mail_schedule
  attr_accessible :mail_schedule_attributes

  belongs_to :user

  after_create :create_next_occurrence

  # Reference: http://stackoverflow.com/questions/4252349/rail-3-where-condition-using-not-null
  scope :with_schedule, joins(:mail_schedule).where(mail_schedules: { datetime: MailSchedule.arel_table[:datetime].not_eq(nil) })

  def is_scheduled?
    self.mail_schedule.present?
  end

  def is_recurring?
    (self.is_scheduled? and self.mail_schedule.recurring)
  end

  def to_s
    description = ""
    if is_scheduled?
      mail_schedule = self.mail_schedule
      start_datetime = mail_schedule.datetime
      description = "MailTemplate(##{self.id}) scheduled to be sent starting at #{start_datetime}"

      if is_recurring?
        recurring_interval = mail_schedule.recurring_interval
        recurring_interval_type = mail_schedule.recurring_interval_type
        description << " recurring every #{recurring_interval} #{recurring_interval_type}."
        next_scheduled_occurrence = self.schedule_occurrences.due.order('schedule_occurrences.next_occurrence ASC').first.next_occurrence
        description << "Next occurrence is scheduled at: #{next_scheduled_occurrence}"
      end
    else
      description = "Unscheduled MailTemplate(##{self.id})"
    end
    description
  end

  def self.create_mail_template(subject, content, recipients_str, schedule_info_hash, user_id)
    mail_template_attrs = create_mail_template_attrs_hash(subject, content, recipients_str, schedule_info_hash, user_id)

    mail_template = nil
    if required_details_available?(mail_template_attrs)
      existing_recipients_email_arr = segregate_existing_and_new_recipients(mail_template_attrs).first
      mail_template = MailTemplate.create(mail_template_attrs)

      unless existing_recipients_email_arr.empty?
        mail_template.recipients << Recipient.where(email: existing_recipients_email_arr)
      end
    else
      Rails.logger.debug "Could not create MailTemplate.Required values for attributes #{required_attributes} not found."
    end

    mail_template
  end

  def update_mail_template(subject, content, recipients_str, schedule_info_hash)
    updated_mail_template_attrs = MailTemplate.create_mail_template_attrs_hash(subject, content, recipients_str, schedule_info_hash, self.user.id)

    if MailTemplate.required_details_available?(updated_mail_template_attrs)

      # Deleting current mail_recipients associations for mail
      MailRecipient.delete(self.mail_recipients.collect { |mr| mr.id })

      existing_recipients_email_arr = MailTemplate.segregate_existing_and_new_recipients(updated_mail_template_attrs).first

      self.update_attributes(updated_mail_template_attrs)

      unless existing_recipients_email_arr.empty?
        self.recipients << Recipient.where(email: existing_recipients_email_arr)
      end
    else
      Rails.logger.debug "Could not update Mail[id: #{self.id}].Required values for attributes #{MailTemplate.required_attributes} not found."
    end
  end

  def create_next_occurrence
    if self.is_scheduled?
      scheduled_datetime = self.mail_schedule.datetime

      if scheduled_datetime < Time.now.utc
        # Send it now
        BulkMailer.delay.general_mail(self.id)
      else
        create_schedule_occurrence(scheduled_datetime)
      end
    end
  end

  def create_schedule_occurrence(next_occurrence)
    ScheduleOccurrence.create(next_occurrence: next_occurrence, scheduled_entity_id: self.id, occurrence_status: 'due')
  end

  private

  def self.required_attributes
    [ :subject, :content, :recipients_attributes, :user_id ]
  end

  def self.required_details_available?(attrs_hash)
    available_attributes = attrs_hash.keys
    if ( (required_attributes - available_attributes).empty? )
      return true
    end
    return false
  end

  def self.create_mail_template_attrs_hash(subject, content, recipients_str, schedule_info_hash, user_id)
    mail_template_attrs = {}
    mail_template_attrs[:subject] = subject if subject.present?
    mail_template_attrs[:content] = content if content.present?

    add_recipients(recipients_str, mail_template_attrs)
    mail_template_attrs[:mail_schedule_attributes] = Hash[schedule_info_hash] if schedule_info_hash.present?
    mail_template_attrs[:user_id] = user_id if user_id.present?
    mail_template_attrs
  end

  def self.add_recipients(recipients_str, mail_template_attrs)
    if recipients_str.present?
      emails_arr = Recipient.csv_to_emails_arr(recipients_str)
      mail_template_attrs[:recipients_attributes] = emails_arr.collect { |email| { email: email } }
    end
  end

  def self.segregate_existing_and_new_recipients(mail_template_attrs)
    emails_arr = emails_from_recipients_attributes(mail_template_attrs)
    segregated_recipients = Recipient.segregate_existing_and_new_recipients(emails_arr)
    existing_recipients_email_arr = segregated_recipients.first
    # A must step, else duplicate recipients shall get created in RECIPIENTS
    # table when Mail instance is created/updated
    remove_existing_recipient_emails_from_attrs(existing_recipients_email_arr, mail_template_attrs)

    new_recipients_email_arr = segregated_recipients.last

    [ existing_recipients_email_arr, new_recipients_email_arr ]
  end

  def self.emails_from_recipients_attributes(mail_template_attrs)
    mail_template_attrs[:recipients_attributes].collect { |hash| hash[:email] }
  end

  def self.remove_existing_recipient_emails_from_attrs(existing_recipients_email_arr, mail_template_attrs)
    # Remove existing recipients emails from mail_template_attrs[:recipients_attributes]
    # list
    unless existing_recipients_email_arr.empty?
      mail_template_attrs[:recipients_attributes].delete_if { |hash| existing_recipients_email_arr.include?(hash[:email]) }
    end
  end

end
