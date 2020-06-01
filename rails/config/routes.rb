Rails.application.routes.draw do
  root to: 'statics#home'

  # Auth0 routes
  get     "/auth/auth0/callback", to: "auth0#callback", as: :auth0_callback
  get     "/auth/failure",        to: "auth0#failure",  as: :auth0_failure
  delete  "/auth/logout",         to: "auth0#logout",   as: :auth0_logout

  # Article pages
  get     "/articles",            to: "articles#index",   as: :articles
  post    "/articles",            to: "articles#create",  as: :create_articles
  delete  "/articles/:id",        to: "articles#destroy", as: :delete_article
  get     "/articles/:id/edit",   to: "articles#edit",    as: :edit_article
  patch   "/articles/:id/edit",   to: "articles#update",  as: :update_article

  # active admin
  ActiveAdmin.routes(self)
end
