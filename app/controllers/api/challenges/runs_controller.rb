# frozen_string_literal: true

class API::Challenges::RunsController < API::BaseController
  before_action :authenticate_user_for_api
  before_action :set_challenge

  def create
    @result = @challenge.run(params[:code], params[:check])
  end

  private
    def set_challenge
      @challenge = Challenge.preload(:checks).preload(:category).find(params[:challenge_id])
    end
end
