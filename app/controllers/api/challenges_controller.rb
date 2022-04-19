# frozen_string_literal: true

class API::ChallengesController < API::BaseController
  before_action :authenticate_user_for_api
  before_action :authenticate_admin_for_api, only: %i(update)
  before_action :set_challenge, only: %i(run judge)

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

  def run
    @result = @challenge.run(params[:code], params[:check])
  end

  def judge
    @result, @challenge_success = @challenge.judge(params[:code])
    Archivement.find_or_create_by!(user_id: current_user.id, challenge_id: @challenge.id) if current_user && @challenge_success
  end

  private
    def set_challenge
      @challenge = Challenge.preload(:checks).preload(:category).find(params[:challenge_id])
    end

    def challenge_params
      params.require(:challenge).permit(:row_order_position)
    end
end
