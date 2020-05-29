class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper
  
  private
    def redirect_if_logged_in
      redirect_to articles_path if logged_in?
    end

    def redirect_unless_logged_in
      redirect_to root_path unless logged_in?
    end
end
