# frozen_string_literal: true

class CategoriesController < ApplicationController
  before_action :authenticate_user
  before_action :authenticate_admin, except: :index
  before_action :set_category, only: %i(edit update destroy)

  def index
    @categories = Category.preload(:challenges).rank(:row_order).all
  end

  def new
    @category = Category.new
  end

  def edit
  end

  def create
    @category = Category.new(category_params)

    if @category.save
      redirect_to root_path, notice: "カテゴリを登録しました。"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @category.update(category_params)
      redirect_to root_path, notice: "カテゴリを更新しました。"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @category.destroy
      redirect_to root_path, notice: "カテゴリを削除しました。"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private
    def set_category
      @category = Category.find(params[:id])
    end

    def category_params
      params.require(:category).permit(:name, :docker_image, :editor_mode, :command, :extension)
    end
end
