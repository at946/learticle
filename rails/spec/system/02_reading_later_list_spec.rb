feature "Reading later list page", type: :system, js: true do
  background do
    # User1が登録した記事の準備
    @user1 = {uid: "google-oauth2|123456789012345678901", articles: []}
    @user1[:articles].prepend(Article.create(url: "https://qiita.com/at-946/items/1e8acea19cc0b9f31b98", uid: @user1[:uid]))
    @user1[:articles].prepend(Article.create(url: "https://note.com/at946/n/n1fd654316f31", uid: @user1[:uid]))
    @user1[:articles].prepend(Article.create(url: "https://www.wantedly.com/users/128531805", uid: @user1[:uid]))

    #User2が登録した記事の準備
    @user2 = {uid: "google-oauth2|111111111122222222223", articles: []}
    @user2[:articles].prepend(Article.create(url: "https://qiita.com/at-946/items/08de3c9d7611f62b1894", uid: @user2[:uid]))
    @user2[:articles].prepend(Article.create(url: "https://note.com/at946/n/n0bb40f0857ef", uid: @user2[:uid]))
  end

  scenario "【ログイン前】に【/reading_later】にアクセスしようとした場合、【トップページ】がリダイレクトされること" do
    visit articles_path
    expect(current_path).to eq root_path
  end

  scenario "【ログイン後】に【/reading_later】にアクセスしようとした場合、【あとで読むリストページ】が表示されること" do
    login
    visit articles_path
    expect(current_path).to eq articles_path
  end

  scenario "【ログイン】ボタンが表示されないこと" do
    login
    visit articles_path
    expect(page).not_to have_selector "#login_button"
  end

  scenario "【ログアウト】ボタンを選択した場合、【ログイン前】状態になり【トップページ】が表示されること" do
    login
    visit articles_path
    click_on :logout_button

    expect(current_path).to eq root_path
  end

  scenario "ログインユーザーが登録した記事が登録日時降順で表示されていること" do
    [@user1, @user2].each do |user|
      login(uid = user[:uid])
      visit articles_path
      article_cards = find("#article_cards").all(".article-card")
      
      expect(article_cards.count).to eq user[:articles].count

      user[:articles].each_with_index do |article, i|
        # 記事を選択した場合、そのWeb記事のサイトに別タブで遷移すること
        expect(article_cards[i].all("a")[0][:href]).to eq user[:articles][i].url
        expect(article_cards[i].all("a")[0][:target]).to eq "_blank"
        # 記事のOGP画像が表示されること
        expect(article_cards[i].find(".card-image").find("img")[:src]).to eq user[:articles][i].image_url
        # 記事のタイトルが表示されること
        expect(article_cards[i].find(".card-header-title")).to have_text user[:articles][i].title
        # 記事の登録日が表示されること
        expect(article_cards[i].find(".card-content").find(".article-registered-at")).to have_text Time.now.strftime("%Y.%m.%d")
        # @articles[i].created_at.strftime("%Y.%m.%d")
      end

      logout
    end
  end

  scenario "ログインユーザー以外が登録した記事が表示されていないこと" do
    users = [@user1, @user2]
    users.each do |user|
      login(uid = user[:uid])
      visit articles_path
      article_cards = find("#article_cards").all(".article-card")

      rest_users = users.reject {|i| i == user}
      rest_users.each do |rest_user|
        rest_user[:articles].each do |article|
          article_cards.each do |article_card|
            expect(article_card.all("a")[0][:href]).not_to eq article.url
          end
        end
      end
      logout
    end
  end

  scenario "【URL】が未入力の状態で【追加する】ボタンを選択した場合、Articleモデルは作成されず【あとで読むリストページ】で【URL未入力】のエラーメッセージが表示されること" do
    articles_count = Article.count
    login @user1[:uid]
    visit articles_path
    
    fill_in :article_url, with: ""
    click_on :create_article_button

    expect(current_path).to eq articles_path
    expect(page).to have_text "URLに https:// または http:// から始まる文字列を入力してください"
    expect(Article.count).to eq articles_count
  end

  scenario "【URL】にURLフォーマット以外（http:// or https:// 以外）文字列を入力した状態で【追加する】ボタンを選択した場合、Articleモデルは作成されず【あとで読むリストページ】で【URLフォーマットエラー】のエラーメッセージが表示されること" do
    articles_count = Article.count
    login @user1[:uid]
    visit articles_path
    
    fill_in :article_url, with: "ftp://bad_uri.com"
    click_on :create_article_button

    expect(current_path).to eq articles_path
    expect(page).to have_text "URLに https:// または http:// から始まる文字列を入力してください"
    expect(Article.count).to eq articles_count
  end

  scenario "【URL】に2001文字以上の文字列を入力した状態で【追加する】ボタンを選択した場合、Articleモデルは作成されず【あとで読むリストページ】で【URL文字数超過】のエラーメッセージが表示されること" do
    articles_count = Article.count
    login @user1[:uid]
    visit articles_path

    fill_in :article_url, with: "https://" + "a" * 1993
    click_on :create_article_button
    
    expect(current_path).to eq articles_path
    expect(page).to have_text "URLは2000文字以内で入力してください"
    expect(Article.count).to eq articles_count
  end

  scenario "【URL】に存在しないURLを入力した状態で【追加する】ボタンを選択した場合、Articleモデルは作成されず【あとで読むリストページ】で【存在しないページ】のエラーメッセージが表示されること" do
    articles_count = Article.count
    login @user1[:uid]
    visit articles_path

    fill_in :article_url, with: "http://a"
    click_on :create_article_button

    expect(current_path).to eq articles_path
    expect(page).to have_text "URLのページは存在しないようです"
    expect(Article.count).to eq articles_count
  end

  scenario "【URL】に登録したいURLを入力した状態で【追加する】ボタンを選択した場合、Articleモデルが作成され【あとで読むリストページ】の【あとで読むリスト】に登録したWeb記事が表示されること" do
    url = "https://qiita.com/at-946/items/08de3c9d7611f62b1894"
    login @user1[:uid]
    visit articles_path

    articles_count = Article.count
    fill_in :article_url, with: url
    click_on :create_article_button

    expect(current_path).to eq articles_path
    expect(page).not_to have_selector "#error_message_area"
    expect(Article.count).to eq articles_count + 1
  end

  scenario "【URL】にOGPが設定されていないページのURLを入力した状態で【追加する】ボタンを選択した場合、Articleモデルが作成され【あとで読むリストページ】に登録したWeb記事（タイトルがURL、OGPはNo Image）が表示されること" do
    url = "https://www.amazon.co.jp/dp/B0814STTHV/ref=dp-kindle-redirect?_encoding=UTF8&btkr=1"
    login @user1[:uid]
    visit articles_path

    articles_count = Article.count
    fill_in :article_url, with: url
    click_on :create_article_button

    expect(current_path).to eq articles_path
    expect(page).not_to have_selector "#error_message_area"
    
    target_card = find("#article_cards").all(".article-card")[0]
    expect(target_card.find(".card-header-title")).to have_text url
    expect(target_card.find(".card-image").find("img")[:src]).to include "no_image"
    expect(Article.count).to eq articles_count + 1
  end

  scenario "【記事】の【削除】ボタンを選択した場合、【削除確認ダイアログ】が表示されること" do
    login @user1[:uid]
    visit articles_path

    page.dismiss_confirm("#{@user1[:articles][0].title}を削除しますか？") do
      all(".article-card")[0].find(".card-delete-button").click
    end
  end

  scenario "【削除確認ダイアログ】で【キャンセル】を選択した場合、【記事】は削除されず【削除確認ダイアログ】が閉じること" do
    login @user1[:uid]
    visit articles_path
    expect(all(".article-card")[0].all("a")[0][:href]).to eq @user1[:articles][0].url
    articles_count = Article.count

    page.dismiss_confirm do
      all(".article-card")[0].find(".card-delete-button").click
    end

    expect(current_path).to eq articles_path
    expect(all(".article-card")[0].all("a")[0][:href]).to eq @user1[:articles][0].url
    expect(Article.count).to eq articles_count
  end

  scenario "【削除確認ダイアログ】で【OK】を選択した場合、【記事】が削除され【削除確認ダイアログ】が閉じること" do
    delete_article_url = @user1[:articles][0].url
    @user2[:articles].prepend(Article.create(url: delete_article_url, uid: @user2[:uid]))

    # User2の記事が存在することを検証
    login @user2[:uid]
    visit articles_path
    expect(all(".article-card")[0].all("a")[0][:href]).to eq delete_article_url
    logout

    # User1の記事が存在することを検証
    login @user1[:uid]
    visit articles_path
    expect(all(".article-card")[0].all("a")[0][:href]).to eq delete_article_url
    articles_count = Article.count

    # User1の記事を削除
    page.accept_confirm do
      all(".article-card")[0].find(".card-delete-button").click
    end

    # User1の記事が存在しないことを検証
    expect(current_path).to eq articles_path
    expect(all(".article-card")[0].all("a")[0][:href]).not_to eq delete_article_url
    expect(all(".article-card")[0].all("a")[0][:href]).to eq @user1[:articles][1].url
    expect(Article.count).to eq articles_count - 1
    logout
    
    # User2の記事が存在することを検証
    login @user2[:uid]
    visit articles_path
    expect(all(".article-card")[0].all("a")[0][:href]).to eq delete_article_url
    logout
  end
end