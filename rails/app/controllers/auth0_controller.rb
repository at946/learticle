class Auth0Controller < ApplicationController
  def callback
    session[:userinfo] = request.env["omniauth.auth"].slice(:provider, :uid)
    redirect_to articles_path
  end

  def failure
    @error_msg = request.params["ログインに失敗しました"]
  end

  def logout
    reset_session
    redirect_to root_path
  end
end
