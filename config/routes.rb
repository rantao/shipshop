Shipshop::Application.routes.draw do
  resources :orders
  resources :customers

  root to: 'customers#index'


end
