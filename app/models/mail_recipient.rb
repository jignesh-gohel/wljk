class MailRecipient < ActiveRecord::Base
  attr_accessible :mail_template_id, :recipient_id

  belongs_to :mail_template
  belongs_to :recipient
end
