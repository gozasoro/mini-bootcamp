# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Categories", type: :system do
  let!(:category) { create(:category, :ruby) }

  scenario "カテゴリ一覧を表示する" do
    visit categories_path
    expect(page).to have_content category.name
    expect(page).to have_content category.docker_image
    expect(page).to have_content "#{category.command} code.#{category.extension}"
  end

  scenario "カテゴリを作成する" do
    visit new_category_path
    fill_in "カテゴリ名", with: "node_category"
    fill_in "Docker image", with: "node:16.13"
    fill_in "category[command]", with: "node"
    fill_in "category[extension]", with: "js"
    click_button "登録する"

    expect(current_path).to eq categories_path
    expect(page).to have_content "node_category"
    expect(page).to have_content "node:16.13"
    expect(page).to have_content "node code.js"
  end

  scenario "カテゴリを編集する" do
    visit edit_category_path(category)
    fill_in "カテゴリ名", with: "golang_category"
    fill_in "Docker image", with: "golang:1.13"
    fill_in "category[command]", with: "go run"
    fill_in "category[extension]", with: "go"
    click_button "更新する"

    expect(current_path).to eq categories_path
    expect(page).to have_content "golang_category"
    expect(page).to have_content "golang:1.13"
    expect(page).to have_content "go run code.go"
  end

  scenario "カテゴリを削除する" do
    visit edit_category_path(category)
    page.accept_confirm do
      click_link "カテゴリを削除する"
    end

    expect(current_path).to eq categories_path
    expect(page).to have_no_content category.name
    expect(page).to have_no_content category.docker_image
    expect(page).to have_no_content "#{category.command} code.#{category.extension}"
  end
end
