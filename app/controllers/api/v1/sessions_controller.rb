class Api::V1::SessionsController < Devise::SessionsController
  def create
    user = User.find_by(email: params[:user][:email])
    if user.present?
      resource = warden.authenticate!(scope: resource_name, recall: "#{controller_path}#failure")
      sign_in_and_redirect(resource_name, resource)
    else
      render json: { error: "Your account is not yet registered!", status: 300 }, status: 200
    end
  end

  def social
    build_resource
    if resource.save
      sign_in resource

      user = User.find_by_id(current_user.id)
      account = user.accounts.create(params[:account])

      if account.save
        account = user.accounts.where("provider = ?", params[:account][:provider]).last
      end

      sign_out resource

      render json: { token: user.token, status: 200 }, status: 200

    elsif resource.errors[:email][0] == "has already been taken"
      resource = User.find_for_database_authentication(email: params[:user][:email])
      return invalid_login_attempt unless resource

      sign_in resource

      user = User.find_by_id(current_user.id)
      account = user.accounts.where("provider = ?", params[:account][:provider]).last

      if !account.present?
        account = user.accounts.create(params[:account])
        account.save
      end


      sign_out resource

      render json: { token: user.token, status: 200 }, status: 200
    else
      render json: { error: resource, status: 422 }, status: :unprocessable_entity
    end
    
    # for fetching only
    # user = User.find_by(email: params[:user][:email], provider_id: params[:user][:provider_id])
    # if user.present?
    #   resource = User.find_for_database_authentication(email: params[:user][:email])
    #
    #   sign_in resource
    #
    #   user = User.find_by_id(current_user.id)
    #
    #   sign_out resource
    #
    #   render json: { user: @user, status: 200 }, status: 200
    # else
    #   render json: { error: "Your account is not yet registered!", status: 300 }, status: 200
    # end


  end

  def failure
    return render json: { error: "Error with your login or password!", status: 300 }, status: 200
  end

  private
    def sign_in_and_redirect(resource_or_scope, resource=nil)
      scope = Devise::Mapping.find_scope!(resource_or_scope)
      resource ||= resource_or_scope
      sign_in(scope, resource) unless warden.user(scope) == resource

      user = User.find_by_id(current_user.id)

      sign_out resource

      return render json: { token: user.token, status: 200 }, status: 200
    end

    def user_params
      params.require(:user).permit(:email, :password, :latitude, :longitude, :provider_id, :provider)
    end
end
