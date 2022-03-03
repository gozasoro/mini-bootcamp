# frozen_string_literal: true

require "rails_helper"

RSpec.describe Challenge, type: :model do
  describe "バリデーションのテスト" do
    let!(:category) { create(:category, :ruby) }
    let!(:challenge) { create(:challenge, category: category) }
    let(:new_challenge) { build(:challenge, category: category) }

    subject { new_challenge.valid? }

    it "作成したchallengeが有効であること" do
      is_expected.to be true
    end

    context "titleカラム" do
      it "空でないこと" do
        new_challenge.title = ""
        is_expected.to be false
      end

      it "uniqueであること" do
        new_challenge.title = challenge.title
        is_expected.to be false
      end
    end

    context "contentカラム" do
      it "空でないこと" do
        new_challenge.content = ""
        is_expected.to be false
      end
    end

    context "model_answerカラム" do
      it "空でないこと" do
        new_challenge.model_answer = ""
        is_expected.to be false
      end
    end

    context "checks" do
      it "空でないこと" do
        new_challenge.checks = []
        is_expected.to be false
      end
    end
  end
end
