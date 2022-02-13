# frozen_string_literal: true

require "rails_helper"

RSpec.describe Category, type: :model do
  describe "バリデーションのテスト" do
    let!(:category) { create(:category, :ruby) }
    let(:new_category) { build(:category, :node) }

    subject { new_category.valid? }

    it "作成したcategoryが有効であること" do
      is_expected.to be true
    end

    context "nameカラム" do
      it "空でないこと" do
        new_category.name = ""
        is_expected.to be false
      end

      it "uniqueであること" do
        new_category.name = category.name
        is_expected.to be false
      end
    end

    context "docker_imageカラム" do
      it "空でないこと" do
        new_category.docker_image = ""
        is_expected.to be false
      end

      it "uniqueであること" do
        new_category.docker_image = category.docker_image
        is_expected.to be false
      end
    end

    context "editor_modeカラム" do
      it "空でないこと" do
        new_category.docker_image = ""
        is_expected.to be false
      end
    end

    context "commandカラム" do
      it "空でないこと" do
        new_category.command = ""
        is_expected.to be false
      end
    end

    context "extensionカラム" do
      it "空でないこと" do
        new_category.extension = ""
        is_expected.to be false
      end

      it "空白が入っていないこと" do
        new_category.extension = " js"
        is_expected.to be false
      end
    end
  end
end
