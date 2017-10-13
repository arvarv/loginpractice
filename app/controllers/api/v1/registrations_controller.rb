class Api::V1::RegistrationsController < Devise::RegistrationsController

  def create
    build_resource(user_params)
    if resource.save
      sign_in resource

      user = User.find_by_id(resource.id)

      sign_out resource

      render json: { token: user.token, status: 200 }, status: 200
    else
      render json: { errors: errors(resource.errors.to_a), status: 300 }, status: 200
    end
  end

  private
    def user_params
      params.require(:user).permit(:email, :password)
    end

    def errors(resource_errors)
      email_errors = ""
      password_errors = ""

      resource_errors.each do |error|
        if email_error(error) == true
          email_errors = error
        elsif password_error(error)
          password_errors = error
        end
      end

      return { email: email_errors, password: password_errors }
    end

    def email_error(log_error)
      errors = ["Email is invalid", "Email has already been taken"]

      return errors.include? log_error
    end

    def password_error(log_error)
      errors = ["Password is too short (minimum is 8 characters)"]

      return errors.include? log_error
    end
end
