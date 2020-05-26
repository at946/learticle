Rails.application.routes.draw do
  root to: 'articles#index'

  get     "/articles",      to: "articles#index",   as: :articles
  post    "/articles",      to: "articles#create",  as: :create_articles
  delete  "/articles/:id",  to: "articles#destroy", as: :delete_article

  # active admin
  ActiveAdmin.routes(self)
end
