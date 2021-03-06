class VotersController < ApplicationController
  def new
    @poll = Poll.find_by(token: params[:token])
    if Time.now <= @poll.expiration
      @poll.voters.each do |voter|
        if session[:voter] == voter.uuid
          flash[:notice] = "You've already voted on this poll!"
          redirect_to root_path and return
        end
      end
      render :new and return
    else
      redirect_to result_path(@poll.id)
    end
  end

  def create
    @poll = Poll.find_by(token: params[:token])
    Option.increment_counter(:votes, params[:option])
    session[:voter] ||= SecureRandom.uuid
    voter = Voter.find_or_create_by(uuid: session[:voter])
    voter.polls << @poll
    redirect_to vote_path(@poll.token)
  end

  def show
    @poll = Poll.find_by(token: params[:token])
  end
end

