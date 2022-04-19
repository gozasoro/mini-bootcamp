# frozen_string_literal: true

class API::Challenges::JudgesController < API::BaseController
  before_action :authenticate_user_for_api
  before_action :set_challenge

  def create
    @result, @challenge_success = @challenge.judge(params[:code])
    Archivement.find_or_create_by!(user_id: current_user.id, challenge_id: @challenge.id) if current_user && @challenge_success
  end

  private
    def set_challenge
      @challenge = Challenge.preload(:checks).preload(:category).find(params[:challenge_id])
    end
end
