module SessionsHelper
  def logged_in?
    session[:userinfo].present?
  end

  def current_user
    session[:userinfo]
  end
end