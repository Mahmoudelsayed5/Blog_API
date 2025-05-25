require 'sidekiq/web'

Rails.application.routes.draw do
  # Mount Sidekiq dashboard
  mount Sidekiq::Web => '/sidekiq'

  # Mount your API (if defined)
  # mount SomeAPI => '/api'  # Uncomment only if you have defined SomeAPI

  post "/signup", to: "users#create"
  post "/login", to: "sessions#create"

  resources :posts do
    resources :comments, only: [:create, :update, :destroy]
  end

  get "up" => "rails/health#show", as: :rails_health_check

  # root "posts#index"  # Uncomment if you want a default homepage route
end
