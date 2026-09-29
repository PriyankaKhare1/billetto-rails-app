# frozen_string_literal: true

Rails.application.routes.draw do
  root "events#index"

  resources :events, only: [:index, :show] do
    member do
      post :upvote
      post :downvote
    end
  end

  get    "/sign_in",       to: "sessions#new",     as: :sign_in
  get    "/sign_in/*path", to: "sessions#new"
  get    "/sign_up",       to: "sessions#sign_up", as: :sign_up
  get    "/sign_up/*path", to: "sessions#sign_up"
  get    "/clerk/callback", to: "sessions#create",  as: :clerk_callback
  post   "/clerk/callback", to: "sessions#create"
  delete "/sign_out",       to: "sessions#destroy", as: :sign_out

  get "up" => "rails/health#show", as: :rails_health_check

  if Rails.env.test?
    get "/test/sign_in", to: "test_sessions#create", as: :test_sign_in
  end
end
