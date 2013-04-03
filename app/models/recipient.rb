class Recipient < ActiveRecord::Base
  attr_accessible :email

  has_many :mail_recipients, dependent: :destroy
  has_many :mails, through: :mail_recipients

end
