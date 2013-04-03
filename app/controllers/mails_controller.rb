class MailsController < ApplicationController
  before_filter :require_user

  def index
    @schedule_emails_active = true
  end

end
