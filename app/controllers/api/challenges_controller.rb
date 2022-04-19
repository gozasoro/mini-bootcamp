# frozen_string_literal: true

class API::ChallengesController < API::BaseController
  before_action :authenticate_user_for_api
  before_action :authenticate_admin_for_api, only: %i(update)

  def show
    @challenge = Challenge.preload(:checks).preload(:category).find(params[:id])
  end

  def update
    @challenge = Challenge.find(params[:id])
    if @challenge.update(challenge_params)
      head :created
    else
      render json: { messages: @challenge.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private
    def challenge_params
      params.require(:challenge).permit(:row_order_position)
    end
end
