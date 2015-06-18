class Api::SignupController < Api::BaseController
  skip_before_action :doorkeeper_authorize!
  skip_before_action :authenticate_user!
  skip_authorization_check

  def index
    user = User.new(signup_params)

    if user.save
      render json: user, serialzier: UserSerializer, status: 201
    else
      render json: { errors: user.errors }, status: 422
    end
  end

private

  def signup_params
    params.permit(:email, :password)
  end
end
