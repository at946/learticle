feature "Finish reading list page", type: :system, js: true do
  background do
    user_prepare
  end

  # アクセス
  scenario "【ログイン前】に【/articles?type=finish_reading】にアクセスしようとした場合、【トップページ】がリダイレクトされること" do
    visit articles_path(type: :finish_reading)
    expect(page).to have_current_path root_path
  end

  scenario "【ログイン後】に【/articles?type=finish_reading】にアクセスしようとした場合、【読了リストページ】が表示されること" do
    login(@users[0]) do
      visit articles_path(type: :finish_reading)
      expect(page).to have_current_path articles_path(type: :finish_reading)
    end
  end

  # ログイン・ログアウト
  scenario "【ログイン】ボタンが表示されないこと" do
    login(@users[0]) do
      visit articles_path(type: :finish_reading)
      expect(page).not_to have_selector "#login_button"
    end
  end

  scenario "【ログアウト】ボタンを選択した場合、【ログイン前】状態になり【トップページ】が表示されること" do
    login(@users[0], logout: false) do
      visit articles_path(type: :finish_reading)
      click_on :logout_button
      expect(page).to have_current_path root_path
    end
  end

  # ページ遷移
  scenario "【ヘッダー】の【ロゴ】を選択した場合、【あとで読むリストページ】が表示されること" do
    login(@users[0]) do
      visit articles_path(type: :finish_reading)
      click_on :logo
      expect(page).to have_current_path articles_path(type: :reading_later)
    end
  end

  scenario "【フッター】の【利用規約】リンクを選択した場合、【利用規約ページ】が表示されること" do
    login(@users[0]) do
      visit articles_path(type: :finish_reading)
      click_on :tos_link
      expect(page).to have_current_path tos_path
    end
  end

  scenario "【フッター】の【プライバシーポリシー】リンクを選択した場合、【プライバシーポリシーページ】が表示されること" do
    login(@users[0]) do
      visit articles_path(type: :finish_reading)
      click_on :pp_link
      expect(page).to have_current_path pp_path
    end
  end

  scenario "【あとで読む】タブを選択した場合、【あとで読むリストページ】へ遷移すること" do
    login(@users[0]) do
      visit articles_path(type: :finish_reading)
      click_on :reading_later_tab
      expect(page).to have_current_path articles_path(type: :reading_later)
    end
  end

  # 記事表示
  scenario "ログインユーザーが読了した記事が読了日時降順で表示されていること" do
    @users.each_with_index do |user, i|
      login(user) do
        visit articles_path(type: :finish_reading)
        article_cards = find("#article_cards").all(".article-card")

        expect(article_cards.count).to eq @user_articles[i][:fr].count

        @user_articles[i][:fr].each_with_index do |user_article, j|
          article = user_article.article
          article_card = article_cards[j]
          # 記事を選択した場合、そのWeb記事のサイトに別タブで遷移すること
          expect(article_card.all("a")[0][:href]).to eq article.url
          expect(article_card.all("a")[0][:target]).to eq "_blank"
          # 記事のOGP画像が表示されること
          expect(article_card.find(".card-image").find("img")[:src]).to eq article.image_url
          # 記事のタイトルが表示されること
          expect(article_card.find(".card-header-title")).to have_text article.title
          # 記事のメモが登録されている場合、記事のメモが表示されること
          # 記事のメモが登録されていない場合、記事のメモが表示されないこと
          if user_article.memo.present?
            expect(article_card.find(".article-memo")).to have_text user_article.memo
          else
            expect(article_card).not_to have_selector ".article-memo"
          end
        end
      end
    end
  end

  scenario "ログインユーザーが後から読む記事は表示されないこと" do
    @users.each_with_index do |user, i|
      login(user) do
        visit articles_path(type: :finish_reading)
        article_cards = find("#article_cards").all(".article-card")

        @user_articles[i][:rl].each do |user_article|
          expect(page).not_to have_link nil, href: user_article.article.url
        end
      end
    end
  end

  scenario "ログインユーザー以外が読了した記事は表示されないこと" do
    @users.each do |user|
      login(user) do
        visit articles_path(type: :finish_reading)
        article_cards = find("#article_cards").all(".article-card")

        @users.each_with_index do |rest_user, i|
          unless rest_user == user
            @user_articles[i][:fr].each do |user_article|
              expect(page).not_to have_link nil, href: user_article.article.url
            end
          end
        end
      end
    end
  end

  scenario "ログインユーザー以外が後から読む記事は表示されないこと" do
    @users.each do |user|
      login(user) do
        visit articles_path(type: :finish_reading)
        article_cards = find("#article_cards").all(".article-card")

        @users.each_with_index do |rest_user, i|
          unless rest_user == user
            @user_articles[i][:rl].each do |user_article|
              expect(page).not_to have_link nil, href: user_article.article.url
            end
          end
        end
      end
    end
  end

  # あとで読む数の表示
  scenario "あとで読む記事の数が表示されないこと" do
    @users.each_with_index do |user, i|
      login(user) do
        visit articles_path(type: :finish_reading)
        expect(page).not_to have_text "あとで読む記事数：#{@user_articles[i][:rl].count}"
      end
    end
  end

  # 読了数の表示
  scenario "読了記事の数が表示されること" do
    @users.each_with_index do |user, i|
      login(user) do
        visit articles_path(type: :finish_reading)
        expect(page).to have_text "読了記事数：#{@user_articles[i][:fr].count}"
      end
    end
  end

  # あとで読む登録
  scenario "URLを入力できないこと" do
    login(@users[0]) do
      visit articles_path(type: :finish_reading)
      expect(page).not_to have_selector "#article_url"
    end
  end

  # 読了登録
  scenario "【記事】の【読了！】ボタンが存在しないこと" do
    login(@users[0]) do
      visit articles_path(type: :finish_reading)
      find("#article_cards").all(".article-card").each do |article_card|
        expect(article_card).not_to have_selector ".finish-reading-button"
      end
    end
  end

  # コメント編集
  scenario "【記事】の【メモ編集】ボタンを選択した場合、【記事編集ページ】に遷移すること" do
    login(@users[0]) do
      visit articles_path(type: :finish_reading)
      find("#article_cards").all(".article-card")[0].find(".edit-memo-button").click
      expect(page).to have_current_path edit_article_path(@user_articles[0][:fr][0])
    end
  end

  # SNSシェア
  scenario "【記事】の【Tweet】ボタンを選択した場合、【ツイートページ】に遷移すること" do
    login(@users[0]) do
      visit articles_path(type: :finish_reading)
      @user_articles[0][:fr].each_with_index do |user_article, i|
        article = user_article.article
        tweet_button = find("#article_cards").all(".article-card")[i].find("a.article-tweet-button")
        tweet_url = CGI.unescape(tweet_button[:href])
        expect(tweet_button[:href]).to include "https://twitter.com/intent/tweet"
        # 【ツイートページ】の【テキストエリア】に【選択した記事】の【メモ】が入力されていること
        if user_article.memo.present?
          expect(tweet_url).to include user_article.memo
        else
          expect(tweet_url).to include "読みました！"
        end
        # 【ツイートページ】の【テキストエリア】に【選択した記事】の【URL】が入力されていること
        expect(tweet_url).to include article.url
        # 【ツイートページ】の【テキストエリア】に【#Learticle】のハッシュタグが入力されていること
        expect(tweet_url).to include "#Learticle"
      end
    end
  end

  # 記事削除
  scenario "【記事】の【削除】ボタンが存在しないこと" do
    login(@users[0]) do
      visit articles_path(type: :finish_reading)
      target = find("#article_cards").all(".article-card")[0]
      expect(target).not_to have_selector ".card-delete-button"
    end
  end
end