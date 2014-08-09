class PollsController < ApplicationController
  before_action :set_poll, only: [:show, :edit, :update, :vote, :destroy]

  def index
    @polls = current_user.polls.order(params[:sort])
    if @polls.empty?
      render "first_timers"
    end
  end

  def new
    @poll = Poll.new
    @poll.expiration = Time.zone.now + 24.hours
    2.times {@poll.options.build}
  end

  def show
    # GET: takes you to edit or confirm
    render :show if validate_user
  end

  def create
    @poll = Poll.new(poll_params)
    @poll.user = current_user
    if @poll.save
      job = UserMailer.delay(run_at: @poll.expiration).poll_close(@poll)
      @poll.update(job_id: job.id)
      flash[:notice] = "Your poll has been created!"
      redirect_to @poll
    else
      flash[:notice] = "Please enter a question with two answers."
      render "new"
    end
  end

  def edit
    render :edit if validate_user
  end

  def update
    if @poll.update(poll_params)
      flash.now[:notice] = "Successfully updated poll."
      redirect_to poll_path(@poll)
    else
      flash[:notice] = "Something went wrong."
      render :edit
    end
  end

  def destroy
    @poll.destroy
    redirect_to polls_path
  end

  private
  def set_poll
    @poll = Poll.find(params[:id])
  end

  def poll_params
    params.require(:poll).permit(:sort, :question, :expiration, :token, :user_id, :filepicker_url, :options_attributes=>[:answer, :filepicker_url, :id])
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
