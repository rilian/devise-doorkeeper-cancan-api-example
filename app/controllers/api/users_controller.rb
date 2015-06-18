class Api::UsersController < Api::BaseController
  load_and_authorize_resource except: %i[update create]
  load_and_authorize_resource param_method: :update_params, on: :update
  load_and_authorize_resource param_method: :create_params, on: :create

  def index
    users = User.accessible_by(current_ability).all

    render json: { users: users }, each_serializer: UserSerializer
  end

  def update
    user = User.find(params[:id])
    if user.update(update_params)
      render json: user, serialzier: UserSerializer, status: 200
    else
      render json: { errors: user.errors }, status: 422
    end
  end

private

  def update_params
    params.permit(:email, :password)
  end
end
