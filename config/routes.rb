YouTrade::Application.routes.draw do
  get "channel/index"
  root :to => "home#index"
  devise_for :users, :controllers => {:registrations => "registrations"}
  resources :users
end