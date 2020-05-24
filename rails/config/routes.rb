Rails.application.routes.draw do
  root to: 'articles#index'

  get   "/articles", to: "articles#index", as: :articles
  post  "/articles", to: "articles#create",  as: :create_articles
  resources :articles, only: [:index, :create]

  # active admin
  ActiveAdmin.routes(self)
end
