class MailSchedule < ActiveRecord::Base
  attr_accessible :datetime, :mail_id, :recurring, :recurring_interval, :recurring_interval_type

  belongs_to :mail

  def formatted_datetime
    return '' unless self.datetime.present?
    self.datetime.strftime('%b %d, %Y | %H:%M:%S %Z')
  end

  def formatted_recurring_message
    return '' unless self.recurring
    interval_type = ( (self.recurring_interval == 1) ? self.recurring_interval_type.singularize : self.recurring_interval_type)
    "every #{self.recurring_interval} #{interval_type}"
  end
end
