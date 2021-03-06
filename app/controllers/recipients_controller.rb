class RecipientsController < ApplicationController
  before_action :set_poll, only: [:index, :new, :create]
  def index
    @recipients = session[:recipients]
  end

  def new
    render :new if validate_user
  end

  def create
    @message = params[:message]    
    session[:recipients] = params[:recipients]
    @recipients = session[:recipients]
    @invalid_emails = []

    @recipients.split(",").each do |email|
      email = email.strip
      email_errors = ValidatesEmailFormatOf::validate_email_format(email)
      @invalid_emails.push(email) if (email_errors && !email.empty?)
    end

    if @recipients.empty?
      flash.now[:error] = "No emails entered"
      render :new
    elsif @invalid_emails.empty?
      @recipients.split(",").each do |email|
        UserMailer.poll_sender(@poll, email, @message).deliver
      end
      redirect_to poll_recipients_path(@poll)
    else
      flash.now[:error] = "The following emails are invalid: #{@invalid_emails.join(', ')}"
      render :new
    end
  end

  private
  def set_poll
    @poll = Poll.find(params[:poll_id])
  end

  def poll_params
    params.require(:recipient).permit(:email, :poll_id)
  end

  def validate_user
    if user_signed_in?
      if current_user.id == @poll.user_id
        return true
      end
    else
      flash[:notice] = "Uh oh, I don't think you have access to this poll!"
      redirect_to root_path and return
    end
  end
end
