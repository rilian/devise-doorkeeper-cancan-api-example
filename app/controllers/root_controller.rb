class RootController < ApplicationController
  clear_respond_to
  respond_to :json

  def index
    render json: { errors: ['Please check API documentation'] }
  end
end
