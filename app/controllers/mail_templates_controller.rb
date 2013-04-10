class MailTemplatesController < ApplicationController
  before_filter :require_user

  before_filter :set_active, only: [ :index, :new, :edit ]
  before_filter :find_mail_template, only: [ :show, :edit, :update, :destroy ]

  #GET  /mail_templates(.:format)
  def index
    @existing_mail_templates = current_user.mail_templates
    #send_scheduled_mail(@existing_mail_templates.first) #TODO
  end

  #GET  /mail_templates/new(.:format)
  def new
  end

  #GET  /mail_templates/:id/edit(.:format)
  def edit
  end

  #GET /mail_templates/:id(.:format)
  def show
  end

  #POST /mail_templates(.:format)
  def create
    MailTemplate.create_mail_template(params[:subject], params[:mail_content], params[:recipients], schedule_info_hash, current_user.id)
    redirect_to mail_templates_path
  end

  #PUT /mail_templates/:id(.:format)
  def update
    @mail_template.update_mail_template(params[:subject], params[:mail_content], params[:recipients], schedule_info_hash)
    #redirect_to mail_templates_path(@mail_template) TODO redirect to show action
    redirect_to mail_templates_path
  end

  #DELETE /mail_templates/:id(.:format)
  def destroy
    @mail_template.destroy
    redirect_to mail_templates_path, notice: 'Successfully deleted mail template.'
  end

  private

  def set_active
    @schedule_emails_active = true
  end

  def find_mail_template
    @mail_template = MailTemplate.find_by_id(params[:id])
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

  def send_scheduled_mail(mail_template)
    error_msg = nil
    if mail_template.present?
      id = mail_template.id
      subject = mail_template.subject
      mail_schedule = mail_template.mail_schedule
      begin
        BulkMailer.general_mail(mail_template).deliver
        mail_sent = true
      rescue Exception => e
        error_msg = "Exception occured while trying to send mail."
        error_msg << "MailTemplate details[ id: #{id}, subject: #{subject}] "
        if mail_schedule.present?
          error_msg << "scheduled at #{mail_schedule.formatted_datetime} #{mail_schedule.formatted_recurring_message}"
        end
        error_msg << ".Technical cause: #{e.to_s}"
        mail_sent = false
      end
    else
      error_msg = 'Could not send email.MailTemplate object found nil.'
    end

    Rails.logger.debug "Error occuring while sending mail: #{error_msg}}" if error_msg.present?
    Rails.logger.debug "Mail sent: #{mail_sent}}"
  end


end
