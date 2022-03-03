# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Categories", type: :request do
  include LoginSupport
  let!(:category_first) { create(:category, :ruby) }
  let!(:category_second) { create(:category, :node) }
  let(:req_params) { { category: { row_order_position: 0 } } }
  let(:headers) { { 'X-Requested-With': "XMLHttpRequest" } }

  context "管理者ではない場合" do
    before do
      login_for_api
    end

    it "エラーが返ってくること" do
      patch api_category_path(category_second), params: req_params, headers: headers
      expect(response).to have_http_status(401)
    end
  end

  context "管理者の場合" do
    before do
      login_as_admin_for_api
    end

    it "カテゴリーの順番を変更できる" do
      expect(Category.rank(:row_order).first.id).to be category_first.id
      patch api_category_path(category_second), params: req_params, headers: headers
      expect(Category.rank(:row_order).first.id).to be category_second.id
      expect(response).to have_http_status(201)
    end
  end
end
