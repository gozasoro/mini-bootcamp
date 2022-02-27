# frozen_string_literal: true

class SessionsController < ApplicationController
  def create
    user = User.find_or_create_from_auth_hash!(auth_hash)
    session[:user_id] = user.id
    redirect_to root_path, notice: "login success"
  end

  def destroy
    reset_session
    redirect_to root_path, notice: "logout success"
  end

  private
    def auth_hash
      request.env["omniauth.auth"]
    end
end
