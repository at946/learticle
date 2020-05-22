Rails.application.routes.draw do
  root to: 'articles#index'

  resources :articles, only: [:index, :create]

  # active admin
  ActiveAdmin.routes(self)
end
