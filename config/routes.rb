Rails.application.routes.draw do
  root "sessions#new"

  get  "/login",  to: "sessions#new"
  post "/login",  to: "sessions#create"
  delete "/logout", to: "sessions#destroy"

  resources :subscriptions, only: [ :index ]

  namespace :webhooks do
    post "stripe", to: "stripe#create", defaults: { format: :json }
  end
end
