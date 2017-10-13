class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format == 'application/json' }

  def authorized_user
    @user = User.find_by(token: params[:token])
    if @user.present? && params[:token].present?
      return @user
    else
      return render json: { error: "You are not authorized to perform this action!", status: 300 }, status: 200
    end
  end
end
