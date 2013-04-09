class MailsController < ApplicationController
  before_filter :require_user

  before_filter :set_active, only: [ :index, :new, :edit ]
  before_filter :find_mail, only: [ :edit, :update, :destroy ]

  #GET  /mails(.:format)
  def index
    @existing_mails = current_user.mails
  end

  #GET  /mails/new(.:format)
  def new
  end

  #GET  /mails/:id/edit(.:format)
  def edit
  end

  def schedule_info_hash
    hash = {}
    scheduleDateTime = params[:scheduleDateTime]
    hash[:datetime] = scheduleDateTime.to_datetime if scheduleDateTime.present?

    if hash[:datetime].present?
      recurring_interval = params[:recurring_interval]
      recurring_interval_type = params[:recurring_interval_type]
      if (recurring_interval.present? and recurring_interval_type.present?)
        recurring_interval_int = recurring_interval.to_i
        if recurring_interval_int > 0
          hash[:recurring] = true
          hash[:recurring_interval] = recurring_interval_int
          hash[:recurring_interval_type] = recurring_interval_type
        else
          Rails.logger.debug "Recurring interval value found <= 0"
        end
      else
        Rails.logger.debug "Recurring interval value and Recurring interval type found missing."
      end
    else
      Rails.logger.debug "Schedule datetime found missing."
    end
    hash
  end

  #POST /mails(.:format)
  def create
    Mail.create_mail(params[:subject], params[:mail_content], params[:recipients], schedule_info_hash, current_user.id)
    redirect_to mails_path
  end

  #PUT /mails/:id(.:format)
  def update
    @mail.update_mail(params[:subject], params[:mail_content], params[:recipients], schedule_info_hash)
    #redirect_to mail_path(@mail) TODO redirect to show action
    redirect_to mails_path
  end

  #DELETE /mails/:id(.:format)
  def destroy
    @mail.destroy
    redirect_to mails_path, notice: 'Successfully deleted mail.'
  end

  private

  def set_active
    @schedule_emails_active = true
  end

  def find_mail
    @mail = Mail.find_by_id(params[:id])
  end


end
