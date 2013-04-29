class MyWorker
  include Sidekiq::Worker
  # https://github.com/tobiassvn/sidetiq#readme - Introduction section
  include Sidetiq::Schedulable

  # https://github.com/tobiassvn/sidetiq#readme - Backfills section
  tiq backfill: true do
    minutely(1)
  end

  # https://github.com/mperham/sidekiq/wiki/Advanced-Options
  # http://stackoverflow.com/questions/16194562/sidekiq-worker-using-a-a-custom-queue-name-gets-assigned-to-default-queue
  # https://github.com/mperham/sidekiq/issues/872
  # https://github.com/mperham/sidekiq/wiki/Delayed-Extensions
  sidekiq_options(backtrace: true, queue: :bulk_mails)

  def perform(last_occurence, current_occurence)
    now = Time.now.utc
    due_schedules = ScheduleOccurrence.due_before(now)

    Sidekiq.logger.debug "========Found #{due_schedules.size} due schedules occurrences before #{now}"

    due_schedules.each do |occurrence|
      mail_template_id = occurrence.scheduled_entity_id
      mail_template = MailTemplate.find(mail_template_id)
      last_occurrence_at = occurrence.next_occurrence

      Sidekiq.logger.debug "========Processing MailTemplate(##{mail_template_id}) scheduled at #{last_occurrence_at}"

      begin
        # Send email
        BulkMailer.general_mail(mail_template_id).deliver
        # Update ScheduleOccurence status to done
        occurrence.update_attribute(:occurrence_status, 'done')
        # Create next occurrence, if recurring schedule
        create_next_occurrence(mail_template, last_occurrence_at, 'due') if mail_template.is_recurring?
      rescue Exception => e
        exception_str = "========Exception occured while processing MailTemplate(##{mail_template_id})."
        exception_str << "Technical Cause: #{e.to_s}"
        Sidekiq.logger.debug exception_str
      end

    end
  end

  private

  def create_next_occurrence(mail_template, last_occurrence_at, status)
    Sidekiq.logger.debug "===========Creating next occurrence for MailTemplate #{mail_template.id}"

    # If recurring schedule, create a new ScheduleOccurence
    # E.g. last_occurrence_at + 1.send(hours)
    mail_schedule = mail_template.mail_schedule
    recurring_interval = mail_schedule.recurring_interval
    recurring_interval_type = mail_schedule.recurring_interval_type
    next_occurrence_at = last_occurrence_at + recurring_interval.send(recurring_interval_type.to_sym)
    mail_template.create_schedule_occurrence(next_occurrence_at)
  end
end