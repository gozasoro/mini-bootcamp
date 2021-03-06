# frozen_string_literal: true

class ChallengesController < ApplicationController
  before_action :authenticate_user
  before_action :authenticate_admin, except: :show
  before_action :set_category, only: %i(index new create)
  before_action :set_category_and_challenge, only: %i(show edit update)
  before_action :set_category_archivements_and_challenge, only: :destroy

  def show
  end

  def new
    @challenge = @category.challenges.new
    @challenge.checks.build
  end

  def edit
  end

  def create
    @challenge = @category.challenges.new(challenge_params)

    if @challenge.save
      redirect_to category_challenge_url(@category, @challenge), notice: "プログラミングテストを作成しました。"
    else
      @challenge.checks.build if @challenge.checks.size == 0
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @challenge.update(challenge_params)
      redirect_to category_challenge_url(@category, @challenge), notice: "プログラミングテストを更新しました。"
    else
      @challenge.checks.build if @challenge.checks.size == 0
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @challenge.destroy
      redirect_to root_path, notice: "プログラミングテストを削除しました。"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private
    def set_category
      @category = Category.find(params[:category_id])
    end

    def set_category_and_challenge
      @category = Category.find(params[:category_id])
      @challenge = @category.challenges.preload(:checks).find(params[:id])
    end

    def set_category_archivements_and_challenge
      @category = Category.find(params[:category_id])
      @challenge = @category.challenges.preload(:archivements).preload(:checks).find(params[:id])
    end

    def challenge_params
      params.require(:challenge).permit(:title, :content, :model_answer, checks_attributes: %i(id stdin stdout _destroy))
    end
end
