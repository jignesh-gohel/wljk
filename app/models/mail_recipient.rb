class MailRecipient < ActiveRecord::Base
  attr_accessible :mail_id, :recipient_id

  belongs_to :mail
  belongs_to :recipient
end
