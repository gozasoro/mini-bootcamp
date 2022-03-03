# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Challenges", type: :request do
  include LoginSupport
  let!(:category) { create(:category, :ruby) }
  let!(:challenge_first) { create(:challenge, category: category) }
  let!(:challenge_second) { create(:challenge, category: category) }
  let(:req_params) { { challenge: { row_order_position: 0 } } }
  let(:headers) { { 'X-Requested-With': "XMLHttpRequest" } }

  context "管理者ではない場合" do
    before do
      login_for_api
    end

    it "エラーが返ってくること" do
      patch api_challenge_path(challenge_second), params: req_params, headers: headers
      expect(response).to have_http_status(401)
    end
  end

  context "管理者の場合" do
    before do
      login_as_admin_for_api
    end

    it "プログラミングテストの順番を変更できる" do
      expect(Challenge.rank(:row_order).first.id).to be challenge_first.id
      patch api_challenge_path(challenge_second), params: req_params, headers: headers
      expect(Challenge.rank(:row_order).first.id).to be challenge_second.id
      expect(response).to have_http_status(201)
    end
  end
end
