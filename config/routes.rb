Rails.application.routes.draw do
  root "static_pages#home"

  get "/login", to: "sessions#new"
  post "/login", to: "sessions#create"
  delete "/logout", to: "sessions#destroy"

  get "demo_partials/new"
  get "demo_partials/edit"
  get "static_pages/home"
  get "static_pages/help"
  
  get "/signup", to: "users#new"
  post "/signup", to: "users#create"
  resources :users
  resources :password_resets, only: %i(new create edit update)
  resources :account_activations, only: :edit
  resources :products

  resources :microposts, only: %i(create destroy)
end
