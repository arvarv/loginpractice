class Api::V1::FriendRequestsController < ApplicationController
  before_action :set_friend_request, except: [:index, :create]
  before_filter :authorized_user
  
  def create
    friend = User.find(params[:friend_id])
    @friend_request = @user.friend_requests.new(friend: friend)

    if @friend_request.save
      render :show, status: :created, location: @friend_request
    else
      render json: @friend_request.errors, status: :unprocessable_entity
    end
  end
  
  private
  def set_friend_request
    @friend_request = FriendRequest.find(params[:id])
  end

end