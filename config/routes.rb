# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :api, defaults: { format: "json" } do
    resources :categories, only: %i(update)
    resources :challenges, only: %i(show update)
  end
  resources :categories, expect: %i(show) do
    resources :challenges
  end

  get "/auth/:provider/callback", to: "sessions#create"
  delete "/logout", to: "sessions#destroy"

  root "categories#index"
end
