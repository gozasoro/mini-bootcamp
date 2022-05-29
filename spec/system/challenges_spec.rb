# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Challenges", type: :system do
  include LoginSupport
  let!(:category) { create(:category, :ruby) }
  let!(:challenge) { create(:challenge, category: category) }

  describe "作成・編集・削除" do
    context "管理者でない場合" do
      before do
        login
      end

      it "プログラミングテスト作成画面にアクセスできない" do
        visit new_category_challenge_path(category)
        expect(current_path).to eq root_path
      end

      it "プログラミングテスト編集画面にアクセスできない" do
        visit edit_category_challenge_path(category, challenge)
        expect(current_path).to eq root_path
      end
    end

    context "管理者の場合" do
      before do
        login_as_admin
      end

      it "プログラミングテストを作成する" do
        visit new_category_challenge_path(category)
        fill_in "タイトル", with: "テストのタイトル"
        fill_in "問題文", with: "テストの問題文"
        fill_in "模範解答", with: "テストの模範解答"
        fill_in "標準入力", with: "テストの標準入力"
        fill_in "期待される出力", with: "テストの期待される出力"

        expect { click_button "登録する" }.to change { Challenge.count }.by(1)

        expect(current_path).to eq category_challenge_path(category, Challenge.last)
        expect(page).to have_content "プログラミングテストを作成しました。"
        expect(page).to have_content "テストのタイトル"
        expect(page).to have_content "テストの問題文"
        expect(page).to have_content "テストの標準入力"
        expect(page).to have_content "テストの期待される出力"
      end

      it "プログラミングテストを編集する" do
        visit edit_category_challenge_path(category, challenge)
        fill_in "タイトル", with: "編集したテストのタイトル"
        fill_in "問題文", with: "編集したテストの問題文"
        fill_in "模範解答", with: "編集したテストの模範解答"
        fill_in "標準入力", with: "編集したテストの標準入力"
        fill_in "期待される出力", with: "編集したテストの期待される出力"

        click_button "更新する"

        expect(current_path).to eq category_challenge_path(category, challenge)
        expect(page).to have_content "プログラミングテストを更新しました。"
        expect(page).to have_content "編集したテストのタイトル"
        expect(page).to have_content "編集したテストの問題文"
        expect(page).to have_content "編集したテストの標準入力"
        expect(page).to have_content "編集したテストの期待される出力"
      end

      it "プログラミングテストを削除する" do
        visit edit_category_challenge_path(category, challenge)
        count = Challenge.count
        page.accept_confirm do
          click_link "プログラミングテストを削除する"
        end

        expect(current_path).to eq root_path
        expect(page).to have_content "プログラミングテストを削除しました。"
        expect(page).to have_no_content challenge.title
        count_now = Challenge.count
        expect(count_now - count).to be(-1)
      end
    end
  end

  describe "表示・実行・判定" do
    let(:user) { User.preload(:archivements).find_by(name: "user") }
    let(:docker_container_mock) { double("Docker container") }
    before do
      login
      allow(docker_container_mock).to receive(:start).and_return(nil)
      allow(docker_container_mock).to receive(:exec).and_return([
        [challenge.checks.first.stdout], [], 0
      ])
      allow(docker_container_mock).to receive(:stop).and_return(nil)
      allow(Docker::Container).to receive(:create).and_return(docker_container_mock)
    end

    it "プログラミングテストを表示する" do
      visit category_challenge_path(category, challenge)
      expect(page).to have_content challenge.title
      expect(page).to have_content challenge.content
      expect(page).to have_content challenge.checks.first.stdin
      expect(page).to have_content challenge.checks.first.stdout
    end

    it "コードを実行する" do
      visit category_challenge_path(category, challenge)
      first(".ace_text-input", visible: false).set("puts '#{challenge.checks.first.stdout}'")
      click_button "コードを実行"
      expect(page).to have_selector "code.result", text: challenge.checks.first.stdout
    end

    it "コードを判定する(success)" do
      visit category_challenge_path(category, challenge)
      expect(page).to have_content "-/1"
      count = user.archivements.count
      first(".ace_text-input", visible: false).set("puts '#{challenge.checks.first.stdout}'")
      click_button "全てのCheckで確認する"

      expect(page).to have_content "1/1"
      count_now = user.archivements.count
      expect(count_now - count).to be(1)
    end

    it "コードを判定する(failed)" do
      allow(docker_container_mock).to receive(:exec).and_return([
        ["invalid stdout"], [], 0
      ])
      visit category_challenge_path(category, challenge)
      expect(page).to have_content "-/1"
      count = user.archivements.count
      first(".ace_text-input", visible: false).set("puts 'invalid stdout'")
      click_button "全てのCheckで確認する"

      expect(page).to have_content "0/1"
      count_now = user.archivements.count
      expect(count_now - count).to be(0)
    end
  end
end
