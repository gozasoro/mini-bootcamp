# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :api, defaults: { format: "json" } do
    resources :categories, only: %i(update)
    resources :challenges, only: %i(show update) do
      post "/run", to: "challenges#run"
      post "/judge", to: "challenges#judge"
    end
  end
  resources :categories, except: %i(show) do
    resources :challenges
  end

  get "/auth/:provider/callback", to: "sessions#create"
  delete "/logout", to: "sessions#destroy"

  root "categories#index"
end
