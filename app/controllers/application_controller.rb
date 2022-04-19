# frozen_string_literal: true

class ApplicationController < ActionController::Base
  helper_method :current_user, :logged_in?, :authenticate_user

  private
    def current_user
      logged_in? ? User.find_by_id(session[:user_id]) : nil
    end

    def logged_in?
      !!session[:user_id]
    end

    def authenticate_user
      redirect_to login_path, notice: "ログインしてください。" unless logged_in?
    end

    def authenticate_admin
      redirect_to root_path unless logged_in? && current_user.admin
    end
end
