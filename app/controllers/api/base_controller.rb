# frozen_string_literal: true

class API::BaseController < ApplicationController
  before_action :check_xhr, :authenticate_user_for_api

  private
    def check_xhr
      head :unprocessable_entity unless request.xhr?
    end

    def authenticate_user_for_api
      head :unauthorized unless logged_in?
    end

    def authenticate_admin_for_api
      head :unauthorized unless logged_in? && current_user.admin
    end
end
