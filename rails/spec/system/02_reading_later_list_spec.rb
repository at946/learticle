feature "Reading later list page", type: :system, js: true do
  background do
    user_prepare
  end

  # アクセス
  scenario "【ログイン前】に【/articles?type=reading_later】にアクセスしようとした場合、【トップページ】がリダイレクトされること" do
    visit articles_path(type: :reading_later)
    expect(page).to have_current_path root_path
  end

  scenario "【ログイン後】に【/articles?type=reading_later】にアクセスしようとした場合、【あとで読むリストページ】が表示されること" do
    login do
      visit articles_path(type: :reading_later)
      expect(page).to have_current_path articles_path(type: :reading_later)
    end
  end

  # ログイン・ログアウト
  scenario "【ログイン】ボタンが表示されないこと" do
    login do
      visit articles_path(type: :reading_later)
      expect(page).not_to have_selector "#login_button"
    end
  end

  scenario "【ログアウト】ボタンを選択した場合、【ログイン前】状態になり【トップページ】が表示されること" do
    login(logout: false) do
      visit articles_path(type: :reading_later)
      click_on :logout_button
      expect(page).to have_current_path root_path
    end
  end

  # ページ遷移
  scenario "【読了】タブを選択した場合、【読了リストページ】へ遷移すること" do
    login(uid: @user1[:uid]) do
      visit articles_path(type: :reading_later)
      click_on :finish_reading_tab
      expect(page).to have_current_path articles_path(type: :finish_reading)
    end
  end

  # コンテンツ表示
  scenario "ログインユーザーが登録した記事が登録日時昇順で表示されていること" do
    @users.each do |user|
      login(uid: user[:uid]) do
        visit articles_path(type: :reading_later)
        article_cards = find("#article_cards").all(".article-card")
        articles = user[:reading_later_articles]
      
        expect(article_cards.count).to eq articles.count

        articles.each_with_index do |article, i|
          # 記事を選択した場合、そのWeb記事のサイトに別タブで遷移すること
          expect(article_cards[i].all("a")[0][:href]).to eq article.url
          expect(article_cards[i].all("a")[0][:target]).to eq "_blank"
          # 記事のOGP画像が表示されること
          expect(article_cards[i].find(".card-image").find("img")[:src]).to eq article.image_url
          # 記事のタイトルが表示されること
          expect(article_cards[i].find(".card-header-title")).to have_text article.title
          # 記事のメモが表示されないこと
          expect(article_cards[i]).not_to have_selector ".article-memo"
        end
      end
    end
  end

  scenario "ログインユーザーが読了した記事は表示されないこと" do
    @users.each do |user|
      login(uid: user[:uid]) do
        visit articles_path(type: :reading_later)
        article_cards = find("#article_cards").all(".article-card")

        user[:finish_reading_articles].each do |article|
          article_cards.each do |article_card|
            expect(article_card.all("a")[0][:href]).not_to eq article.url
          end
        end
      end
    end
  end

  scenario "ログインユーザー以外が後から読む記事は表示されないこと" do
    @users.each do |user|
      login(uid: user[:uid]) do
        visit articles_path(type: :reading_later)
        article_cards = find("#article_cards").all(".article-card")

        rest_users = @users.reject {|item| item == user}
        rest_users.each do |rest_user|
          rest_user[:reading_later_articles].each do |article|
            article_cards.each do |article_card|
              expect(article_card.all("a")[0][:href]).not_to eq article.url
            end
          end
        end
      end
    end
  end

  scenario "ログインユーザー以外が読了した記事は表示されないこと" do
    @users.each do |user|
      login(uid: user[:uid]) do
        visit articles_path(type: :reading_later)
        article_cards = find("#article_cards").all(".article-card")

        rest_users = @users.reject {|i| i == user}
        rest_users.each do |rest_user|
          rest_user[:finish_reading_articles].each do |article|
            article_cards.each do |article_card|
              expect(article_card.all("a")[0][:href]).not_to eq article.url
            end
          end
        end
      end
    end
  end

  ### URL登録
  scenario "【URL】が未入力の状態で【あとで読む】ボタンを選択した場合、Articleモデルは作成されず【あとで読むリストページ】で【URL未入力】のエラーメッセージが表示されること" do
    articles_count = Article.count
    login(uid: @user1[:uid]) do
      visit articles_path(type: :reading_later)
    
      fill_in :article_url, with: ""
      click_on :create_article_button

      expect(page).to have_current_path articles_path(type: :reading_later)
      expect(page).to have_text "URLに https:// または http:// から始まる文字列を入力してください"
      expect(Article.count).to eq articles_count
    end
  end

  scenario "【URL】にURLフォーマット以外（http:// or https:// 以外）文字列を入力した状態で【あとで読む】ボタンを選択した場合、Articleモデルは作成されず【あとで読むリストページ】で【URLフォーマットエラー】のエラーメッセージが表示されること" do
    articles_count = Article.count
    login(uid: @user1[:uid]) do
      visit articles_path(type: :reading_later)
    
      fill_in :article_url, with: "ftp://bad_uri.com"
      click_on :create_article_button

      expect(page).to have_current_path articles_path(type: :reading_later)
      expect(page).to have_text "URLに https:// または http:// から始まる文字列を入力してください"
      expect(Article.count).to eq articles_count
    end
  end

  scenario "【URL】に2001文字以上の文字列を入力した状態で【あとで読む】ボタンを選択した場合、Articleモデルは作成されず【あとで読むリストページ】で【URL文字数超過】のエラーメッセージが表示されること" do
    articles_count = Article.count
    login(uid: @user1[:uid]) do
      visit articles_path(type: :reading_later)

      fill_in :article_url, with: "https://" + "a" * 1993
      click_on :create_article_button
    
      expect(page).to have_current_path articles_path(type: :reading_later)
      expect(page).to have_text "URLは2000文字以内で入力してください"
      expect(Article.count).to eq articles_count
    end
  end

  scenario "【URL】に存在しないURLを入力した状態で【あとで読む】ボタンを選択した場合、Articleモデルは作成されず【あとで読むリストページ】で【存在しないページ】のエラーメッセージが表示されること" do
    articles_count = Article.count
    login(uid: @user1[:uid]) do
      visit articles_path(type: :reading_later)

      fill_in :article_url, with: "http://a"
      click_on :create_article_button

      expect(page).to have_current_path articles_path(type: :reading_later)
      expect(page).to have_text "URLのページは存在しないようです"
      expect(Article.count).to eq articles_count
    end
  end

  scenario "【URL】に登録したいURLを入力した状態で【あとで読む】ボタンを選択した場合、Articleモデルが作成され【あとで読むリストページ】の【あとで読むリスト】に登録したWeb記事が表示されること" do
    url = "https://qiita.com/at-946/items/08de3c9d7611f62b1894"
    login(uid: @user1[:uid]) do
      visit articles_path(type: :reading_later)

      articles_count = Article.count
      fill_in :article_url, with: url
      click_on :create_article_button

      expect(page).to have_current_path articles_path(type: :reading_later)
      expect(page).not_to have_selector "#error_message_area"
      expect(find("#article_cards").all(".article-card")[-1].all("a")[0][:href]).to eq url
      expect(Article.count).to eq articles_count + 1
    end
  end

  scenario "【URL】にOGPが設定されていないページのURLを入力した状態で【あとで読む】ボタンを選択した場合、Articleモデルが作成され【あとで読むリストページ】に登録したWeb記事（タイトルがURL、OGPはNo Image）が表示されること" do
    url = "https://www.amazon.co.jp/dp/B0814STTHV/ref=dp-kindle-redirect?_encoding=UTF8&btkr=1"
    login(uid: @user1[:uid]) do
      visit articles_path(type: :reading_later)

      articles_count = Article.count
      fill_in :article_url, with: url
      click_on :create_article_button

      expect(page).to have_current_path articles_path(type: :reading_later)
      expect(page).not_to have_selector "#error_message_area"
    
      target_card = find("#article_cards").all(".article-card")[-1]
      expect(target_card.all("a")[0][:href]).to eq url
      expect(target_card.find(".card-header-title")).to have_text url
      expect(target_card.find(".card-image").find("img")[:src]).to include "no_image"
      expect(Article.count).to eq articles_count + 1
    end
  end

  ### 読了登録
  scenario "【記事】の【読了！】ボタンを選択した場合、【読了登録ページ】へ遷移すること" do
    login(uid: @user1[:uid]) do
      visit articles_path(type: :reading_later)
      article = find("#article_cards").all(".article-card")[0]
      article.find(".finish-reading-button").click
      expect(page).to have_current_path edit_article_path(@user1[:reading_later_articles][0])
    end
  end

  ### 記事削除
  scenario "【記事】の【削除】ボタンを選択した場合、【削除確認ダイアログ】が表示されること" do
    login(uid: @user1[:uid]) do
      visit articles_path(type: :reading_later)

      page.dismiss_confirm("#{@user1[:reading_later_articles][0].title}を削除しますか？") do
        all(".article-card")[0].find(".card-delete-button").click
      end
    end
  end

  scenario "【削除確認ダイアログ】で【キャンセル】を選択した場合、【記事】は削除されず【削除確認ダイアログ】が閉じること" do
    login(uid: @user1[:uid]) do
      visit articles_path(type: :reading_later)
      expect(all(".article-card")[0].all("a")[0][:href]).to eq @user1[:reading_later_articles][0].url
      articles_count = Article.count

      page.dismiss_confirm do
        all(".article-card")[0].find(".card-delete-button").click
      end

      expect(page).to have_current_path articles_path(type: :reading_later)
      expect(all(".article-card")[0].all("a")[0][:href]).to eq @user1[:reading_later_articles][0].url
      expect(Article.count).to eq articles_count
    end
  end

  scenario "【削除確認ダイアログ】で【OK】を選択した場合、【記事】が削除され【削除確認ダイアログ】が閉じること" do
    # 【追加】記事を削除しても、同じ記事を登録している別ユーザーの記事は削除されないこと
    delete_article_url = @user1[:reading_later_articles][0].url
    Article.create(url: delete_article_url, uid: @user2[:uid])

    # User2の記事が存在することを検証
    login(uid: @user2[:uid]) do
      visit articles_path(type: :reading_later)
      expect(all(".article-card")[-1].all("a")[0][:href]).to eq delete_article_url
    end

    # User1の記事が存在することを検証
    login(uid: @user1[:uid]) do
      visit articles_path(type: :reading_later)
      expect(all(".article-card")[0].all("a")[0][:href]).to eq delete_article_url
      articles_count = Article.count

      # User1の記事を削除
      page.accept_confirm do
        all(".article-card")[0].find(".card-delete-button").click
      end

      # User1の記事が存在しないことを検証
      expect(page).to have_current_path articles_path(type: :reading_later)
      expect(all(".article-card")[0].all("a")[0][:href]).not_to eq delete_article_url
      expect(all(".article-card")[0].all("a")[0][:href]).to eq @user1[:reading_later_articles][1].url
      expect(Article.count).to eq articles_count - 1
    end
    
    # User2の記事が存在することを検証
    login(uid: @user2[:uid]) do
      visit articles_path(type: :reading_later)
      expect(all(".article-card")[-1].all("a")[0][:href]).to eq delete_article_url
    end
  end
end