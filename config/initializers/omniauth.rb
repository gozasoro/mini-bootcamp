# frozen_string_literal: true

Rails.application.config.middleware.use OmniAuth::Builder do
  if Rails.env.test?
    provider :github, "client_id", "client_secret", scope: "read:user"
  elsif Rails.env.development?
    provider :github, Rails.application.credentials.dev[:client_id], Rails.application.credentials.dev[:client_secret], scope: "read:user"
  else
    provider :github,
      Rails.application.credentials.github[:client_id],
      Rails.application.credentials.github[:client_secret]
  end
end
