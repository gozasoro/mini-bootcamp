# frozen_string_literal: true

class API::CategoriesController < API::BaseController
  before_action :authenticate_admin_for_api

  def update
    @category = Category.find(params[:id])
    if @category.update(category_params)
      head :created
    else
      render json: { messages: @category.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private
    def category_params
      params.require(:category).permit(:row_order_position)
    end
end
