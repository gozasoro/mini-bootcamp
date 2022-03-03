# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Categories", type: :system do
  include LoginSupport
  let!(:category) { create(:category, :ruby) }
  let!(:category_have_no_challenge) { create(:category, :golang) }
  let!(:challenge) { create(:challenge, category: category) }

  context "管理者ではない場合" do
    before do
      login
    end

    it "カテゴリ・チャレンジ一覧を表示する" do
      visit root_path
      expect(page).to have_content category.name
      expect(page).to have_content challenge.title
      expect(page).to have_no_content "新規プログラミングテスト"
      expect(page).to have_no_selector ".handle"
      expect(page).to have_no_selector ".edit"
    end

    it "カテゴリ作成画面にアクセスできない" do
      visit new_category_path
      expect(current_path).to eq root_path
    end

    it "カテゴリ編集画面にアクセスできない" do
      visit edit_category_path(category)
      expect(current_path).to eq root_path
    end
  end

  context "管理者の場合" do
    before do
      login_as_admin
    end

    it "カテゴリ・チャレンジ一覧を表示する" do
      visit root_path
      expect(page).to have_content category.name
      expect(page).to have_content challenge.title
      expect(page).to have_content "新規プログラミングテスト"
      expect(page).to have_selector ".handle"
      expect(page).to have_selector ".edit"
    end

    it "カテゴリを作成する" do
      visit new_category_path
      expect(current_path).to eq new_category_path
      fill_in "カテゴリ名", with: "node_category"
      fill_in "Docker image", with: "node:16.13"
      fill_in "category[command]", with: "node"
      fill_in "category[extension]", with: "js"
      expect { click_button "登録する" }.to change { Category.count }.by(1)

      expect(current_path).to eq root_path
      expect(page).to have_content "カテゴリを登録しました。"
      expect(page).to have_content "node_category"
    end

    it "カテゴリを編集する" do
      visit edit_category_path(category)
      fill_in "カテゴリ名", with: "golang_category"
      fill_in "Docker image", with: "golang:1.13"
      fill_in "category[command]", with: "go run"
      fill_in "category[extension]", with: "go"
      click_button "更新する"

      expect(current_path).to eq root_path
      expect(page).to have_content "カテゴリを更新しました。"
      expect(page).to have_content "golang_category"
    end

    it "チャレンジがある場合にカテゴリを削除できない" do
      visit edit_category_path(category)
      page.accept_confirm do
        click_link "カテゴリを削除する"
      end

      expect(current_path).to eq "/categories/#{category.id}"
      expect(page).to have_content "プログラミングテストが存在しているので削除できません"
    end

    it "チャレンジがない場合にカテゴリを削除する" do
      visit edit_category_path(category_have_no_challenge)
      page.accept_confirm do
        click_link "カテゴリを削除する"
      end

      expect(current_path).to eq root_path
      expect(page).to have_no_content category_have_no_challenge.name
    end
  end
end
