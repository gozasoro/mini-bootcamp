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
end
