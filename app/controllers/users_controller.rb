class UsersController < ApplicationController
  before_action :authenticate_user

  def destroy
    user = User.preload(:archivements).find_by_id(session[:user_id])
    if user.destroy
      reset_session
      redirect_to root_path, notice: "GitHub連携を解除しました。"
    else
      head :unprocessable_entity
    end
  end
end
