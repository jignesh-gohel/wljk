class Mail < ActiveRecord::Base
  attr_accessible :content

  has_many :mail_recipients, dependent: :destroy
  has_many :recipients, through: :mail_recipients
end
