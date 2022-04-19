# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :api, defaults: { format: "json" } do
    resources :categories, only: %i(update)
    resources :challenges, only: %i(show update) do
      scope module: :challenges do
        resources :runs, only: %i(create)
        resources :judges, only: %i(create)
      end
    end
  end
  resources :categories, except: %i(show) do
    resources :challenges, except: %i(index)
  end

  get "/login", to: "sessions#new"
  get "/auth/:provider/callback", to: "sessions#create"
  delete "/logout", to: "sessions#destroy"
  resources :users, only: %i(destroy)

  root "categories#index"
end
