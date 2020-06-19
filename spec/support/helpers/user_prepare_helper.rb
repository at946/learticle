module UserPrepareHelper
  def user_prepare
    # URLs for Articles
    urls = [
      "https://qiita.com/at-946/items/1e8acea19cc0b9f31b98",
      "https://qiita.com/at-946/items/ffc0ebcc4d08f958197b",
      "https://qiita.com/at-946/items/08de3c9d7611f62b1894",
      "https://qiita.com/at-946/items/2fb75cec5355fad4050d",
      "https://note.com/at946/n/n1fd654316f31",
      "https://note.com/at946/n/nd7e6141bd4c2",
      "https://note.com/at946/n/n0bb40f0857ef",
      "https://note.com/at946/n/n6e43fe983211",
      "https://note.com/at946/n/n61f6c4468e17",
      "https://www.wantedly.com/users/128531805"
    ]

    # user1はあとで読む記事を３つ、読了記事を２つ登録している
    @user1 = create(:user)
    @user1_articles = {rl: [], fr: []}
    3.times do
      article = create(:article, url: urls.shift)
      @user1_articles[:rl].append(create(:user_article, user_id: @user1.id, article_id: article.id))
    end
    2.times do
      article = create(:article, url: urls.shift)
      @user1_articles[:fr].prepend(create(:user_article, user_id: @user1.id, article_id: article.id, finish_reading_at: Time.now, memo: Faker::Hipster.sentence))
    end

    # user2はあとで読む記事を２つ、読了記事を３つ登録している
    @user2 = create(:user)
    @user2_articles = {rl: [], fr: []}
    2.times do
      article = create(:article, url: urls.shift)
      @user2_articles[:rl].append(create(:user_article, user_id: @user2.id, article_id: article.id))
    end
    3.times do
      article = create(:article, url: urls.shift)
      @user2_articles[:fr].prepend(create(:user_article, user_id: @user2.id, article_id: article.id, finish_reading_at: Time.now, memo: Faker::Hipster.sentence))
    end

    @users = [@user1, @user2]
    @user_articles = [@user1_articles, @user2_articles]
  end

  RSpec.configure do |config|
    config.include UserPrepareHelper, type: :system
  end
end