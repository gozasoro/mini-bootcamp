# frozen_string_literal: true

module LoginSupport
  def login
    visit login_path
    click_link "GitHubでログイン"
  end

  def login_as_admin
    allow(Rails.application.credentials).to receive(:admin).and_return("user")
    login
  end

  def login_for_api
    get "/auth/github/callback"
  end

  def login_as_admin_for_api
    allow(Rails.application.credentials).to receive(:admin).and_return("user")
    get "/auth/github/callback"
  end
end
