class Api::V1::UsersController < ApplicationController
  before_filter :authorized_user, except: [:forgot]

def index
  users = User.all.order(:id).page(params[:offset]).per_page(1)

  render json: {users: users, status:200},status: 200
end

def create
  
end
  
end
