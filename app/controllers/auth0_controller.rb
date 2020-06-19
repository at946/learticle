class Auth0Controller < ApplicationController
  def callback
    userinfo = request.env["omniauth.auth"].slice(:provider, :uid, :info)
    user = User.find_by(auth0_uid: userinfo["uid"])

    if user.nil?
      # 未サインアップのユーザーは新しくUserを作成する
      user = User.new(
        auth0_uid: userinfo["uid"],
        name: userinfo["info"]["name"],
        image: userinfo["info"]["image"]
      )
    else
      # サインアップ済のユーザーは情報に更新があった場合のみ更新する
      user.auth0_uid = userinfo["uid"]
      user.name = userinfo["info"]["name"]
      user.image = userinfo["info"]["image"]
    end

    if user.save
      session[:user_id] = user.id
      redirect_to articles_path(type: :reading_later)
    else
      redirect_to root_path
    end    
  end

  def failure
    @error_msg = request.params["ログインに失敗しました"]
  end

  def logout
    reset_session
    redirect_to root_path
  end
end
