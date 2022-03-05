# frozen_string_literal: true

RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by(:selenium, screen_size: [1280, 800]) do |options|
      options.add_argument("--disable-dev-sim-usage")
      options.add_argument("--no-sandbox")
      options.add_argument("--headless")
    end
  end
end
