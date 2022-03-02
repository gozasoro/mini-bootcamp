# frozen_string_literal: true

class SessionsController < ApplicationController
  before_action :authenticate_user, only: %i(destroy)
  def new
  end

  def create
    user = User.find_or_create_from_auth_hash!(auth_hash)
    session[:user_id] = user.id
    redirect_to root_path, notice: "ログインしました。"
  end

  def destroy
    reset_session
    redirect_to login_path, notice: "ログアウトしました。"
  end

  private
    def auth_hash
      request.env["omniauth.auth"]
    end
end
