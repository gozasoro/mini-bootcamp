# frozen_string_literal: true

class Api::ChallengesController < Api::BaseController
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
