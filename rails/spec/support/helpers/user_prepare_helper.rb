module UserPrepareHelper
  def user_prepare
    # User1が登録した記事の準備
    @user1 = {uid: "google-oauth2|123456789012345678901", reading_later_articles: [], finish_reading_articles: []}
    # User1のあとで読む記事
    @user1[:reading_later_articles].push(Article.create(url: "https://qiita.com/at-946/items/1e8acea19cc0b9f31b98", uid: @user1[:uid]))
    @user1[:reading_later_articles].push(Article.create(url: "https://note.com/at946/n/n1fd654316f31", uid: @user1[:uid]))
    @user1[:reading_later_articles].push(Article.create(url: "https://www.wantedly.com/users/128531805", uid: @user1[:uid]))
    # User1の読了記事
    @user1[:finish_reading_articles].prepend(Article.create(url: "https://qiita.com/at-946/items/ffc0ebcc4d08f958197b", uid: @user1[:uid], finish_reading_at: Time.now, memo: "面白かった！"))
    @user1[:finish_reading_articles].prepend(Article.create(url: "https://note.com/at946/n/nd7e6141bd4c2", uid: @user1[:uid], finish_reading_at: Time.now))

    #User2が登録した記事の準備
    @user2 = {uid: "google-oauth2|111111111122222222223", reading_later_articles: [], finish_reading_articles: []}
    # User2のあとで読む記事
    @user2[:reading_later_articles].push(Article.create(url: "https://qiita.com/at-946/items/08de3c9d7611f62b1894", uid: @user2[:uid]))
    @user2[:reading_later_articles].push(Article.create(url: "https://note.com/at946/n/n0bb40f0857ef", uid: @user2[:uid]))
    # User2の読了記事
    @user2[:finish_reading_articles].prepend(Article.create(url: "https://qiita.com/at-946/items/2fb75cec5355fad4050d", uid: @user2[:uid], finish_reading_at: Time.now))
    @user2[:finish_reading_articles].prepend(Article.create(url: "https://note.com/at946/n/n6e43fe983211", uid: @user2[:uid], finish_reading_at: Time.now, memo: "ためになる。\nまた読みたい。"))
    @user2[:finish_reading_articles].prepend(Article.create(url: "https://note.com/at946/n/n61f6c4468e17", uid: @user2[:uid], finish_reading_at: Time.now, memo: "あとでまとめてツイートするぞ！"))

    @users = [@user1, @user2]
  end

  RSpec.configure do |config|
    config.include UserPrepareHelper, type: :system
  end
end