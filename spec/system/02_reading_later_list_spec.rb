feature "Reading later list page", type: :system, js: true do
  background do
    user_prepare
    @user_articles_count = UserArticle.count
    @articles_count = Article.count
  end

  # アクセス
  scenario "【ログイン前】に【/articles?type=reading_later】にアクセスしようとした場合、【トップページ】がリダイレクトされること" do
    visit articles_path(type: :reading_later)
    expect(page).to have_current_path root_path
  end

  scenario "【ログイン後】に【/articles?type=reading_later】にアクセスしようとした場合、【あとで読むリストページ】が表示されること" do
    login(@users[0]) do
      visit articles_path(type: :reading_later)
      expect(page).to have_current_path articles_path(type: :reading_later)
    end
  end

  # ログイン
  scenario "【ログイン】ボタンが表示されないこと" do
    login(@users[0]) do
      visit articles_path(type: :reading_later)
      expect(page).not_to have_selector "#login_button"
    end
  end

  # ログアウト
  scenario "【ログアウト】ボタンを選択した場合、【ログイン前】状態になり【トップページ】が表示されること" do
    login(@users[0], logout: false) do
      visit articles_path(type: :reading_later)
      click_on :logout_button
      expect(page).to have_current_path root_path
    end
  end

  # ページ遷移
  scenario "【ヘッダー】の【ロゴ】を選択した場合、【あとで読むリストページ】が表示されること" do
    login(@users[0]) do
      visit articles_path(type: :reading_later)
      click_on :logo
      expect(page).to have_current_path articles_path(type: :reading_later)
    end
  end

  scenario "【フッター】の【利用規約】リンクを選択した場合、【利用規約ページ】が表示されること" do
    login(@users[0]) do
      visit articles_path(type: :reading_later)
      click_on :tos_link
      expect(page).to have_current_path tos_path
    end
  end

  scenario "【フッター】の【プライバシーポリシー】リンクを選択した場合、【プライバシーポリシーページ】が表示されること" do
    login(@users[0]) do
      visit articles_path(type: :reading_later)
      click_on :pp_link
      expect(page).to have_current_path pp_path
    end
  end

  scenario "【読了】タブを選択した場合、【読了リストページ】へ遷移すること" do
    login(@users[0]) do
      visit articles_path(type: :reading_later)
      click_on :finish_reading_tab
      expect(page).to have_current_path articles_path(type: :finish_reading)
    end
  end


  # 記事表示
  scenario "ログインユーザーが登録した記事が登録日時昇順で表示されていること" do
    @users.each_with_index do |user, i|
      login(user) do
        visit articles_path(type: :reading_later)
        article_cards = find("#article_cards").all(".article-card")
        user_articles = @user_articles[i][:rl]
      
        expect(article_cards.count).to eq user_articles.count

        user_articles.each_with_index do |user_article, i|
          # 記事を選択した場合、そのWeb記事のサイトに別タブで遷移すること
          expect(article_cards[i].all("a")[0][:href]).to eq user_article.article.url
          expect(article_cards[i].all("a")[0][:target]).to eq "_blank"
          # 記事のOGP画像が表示されること
          expect(article_cards[i].find(".card-image").find("img")[:src]).to eq user_article.article.image_url
          # 記事のタイトルが表示されること
          expect(article_cards[i].find(".card-header-title")).to have_text user_article.article.title
          # 記事のメモが表示されないこと
          expect(article_cards[i]).not_to have_selector ".article-memo"
        end
      end
    end
  end

  scenario "ログインユーザーが読了した記事は表示されないこと" do
    @users.each_with_index do |user, i|
      login(user) do
        visit articles_path(type: :reading_later)
        article_cards = find("#article_cards").all(".article-card")

        @user_articles[i][:fr].each do |user_article|
          article = user_article.article
          article_cards.each do |article_card|
            expect(article_card.all("a")[0][:href]).not_to eq article.url
          end
        end
      end
    end
  end

  scenario "ログインユーザー以外が後から読む記事は表示されないこと" do
    @users.each do |user|
      login(user) do
        visit articles_path(type: :reading_later)
        article_cards = find("#article_cards").all(".article-card")

        @users.each_with_index do |rest_user, i|
          unless rest_user == user
            @user_articles[i][:rl].each do |user_article|
              article_cards.each do |article_card|
                expect(article_card.all("a")[0][:href]).not_to eq user_article.article.url
              end
            end
          end
        end
      end
    end
  end

  scenario "ログインユーザー以外が読了した記事は表示されないこと" do
    @users.each do |user|
      login(user) do
        visit articles_path(type: :reading_later)
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
  scenario "あとで読む記事の数が表示されること" do
    @users.each_with_index do |user, i|
      login(user) do
        visit articles_path(type: :reading_later)
        expect(page).to have_text "あとで読む記事数：#{@user_articles[i][:rl].count}"
      end
    end
  end

  # 読了数の表示
  scenario "読了記事数が表示されないこと" do
    @users.each_with_index do |user, i|
      login(user) do
        visit articles_path(type: :reading_later)
        expect(page).not_to have_text "読了記事数：#{@user_articles[i][:fr].count}"
      end
    end
  end

  # あとで読む登録
  scenario "【URL】が未入力の状態で【あとで読む】ボタンを選択した場合、Articleモデルは作成されず【あとで読むリストページ】で【URL未入力】のエラーメッセージが表示されること" do
    url = ""

    login(@users[0]) do
      visit articles_path(type: :reading_later)
    
      fill_in :article_url, with: url
      click_on :create_article_button

      expect(page).to have_current_path articles_path(type: :reading_later)
      expect(page).to have_text "URLに https:// または http:// から始まる文字列を入力してください"
      expect(find("#article_url").value).to eq url
      expect(UserArticle.count).to eq @user_articles_count
      expect(Article.count).to eq @articles_count
    end
  end

  scenario "【URL】にURLフォーマット以外（http:// or https:// 以外）文字列を入力した状態で【あとで読む】ボタンを選択した場合、Articleモデルは作成されず【あとで読むリストページ】で【URLフォーマットエラー】のエラーメッセージが表示されること" do
    url = Faker::Alphanumeric.alphanumeric(number: 100)

    login(@users[0]) do
      visit articles_path(type: :reading_later)
    
      fill_in :article_url, with: url
      click_on :create_article_button

      expect(page).to have_current_path articles_path(type: :reading_later)
      expect(page).to have_text "URLに https:// または http:// から始まる文字列を入力してください"
      expect(find("#article_url").value).to eq url
      expect(UserArticle.count).to eq @user_articles_count
      expect(Article.count).to eq @articles_count
    end
  end

  scenario "【URL】に2001文字以上の文字列を入力した状態で【あとで読む】ボタンを選択した場合、Articleモデルは作成されず【あとで読むリストページ】で【URL文字数超過】のエラーメッセージが表示されること" do
    url = "https://" + Faker::Alphanumeric.alphanumeric(number: 1993)

    login(@users[0]) do
      visit articles_path(type: :reading_later)

      fill_in :article_url, with: url
      click_on :create_article_button
    
      expect(page).to have_current_path articles_path(type: :reading_later)
      expect(page).to have_text "URLは2000文字以内で入力してください"
      expect(find("#article_url").value).to eq url
      expect(UserArticle.count).to eq @user_articles_count
      expect(Article.count).to eq @articles_count
    end
  end

  scenario "【URL】に存在しないURLを入力した状態で【あとで読む】ボタンを選択した場合、Articleモデルは作成されず【あとで読むリストページ】で【存在しないページ】のエラーメッセージが表示されること" do
    url = "https://a"

    login(@users[0]) do
      visit articles_path(type: :reading_later)

      fill_in :article_url, with: url
      click_on :create_article_button

      expect(page).to have_current_path articles_path(type: :reading_later)
      expect(page).to have_text "URLのページは存在しないようです"
      expect(find("#article_url").value).to eq url
      expect(UserArticle.count).to eq @user_articles_count
      expect(Article.count).to eq @articles_count
    end
  end

  scenario "【URL】にすでにログインユーザーが登録しているURLを入力した状態で【あとで読む】ボタンを選択した場合、Articleモデルは作成されず【あとで読むリストページ】で【重複】のエラーメッセージが表示されること" do
    urls = [
      @user_articles[0][:rl].sample.article.url,
      @user_articles[0][:fr].sample.article.url
    ]

    urls.each do |url|
      login(@users[0]) do
        visit articles_path(type: :reading_later)

        fill_in :article_url, with: url
        click_on :create_article_button

        expect(page).to have_current_path articles_path(type: :reading_later)
        expect(page).to have_text "この記事はすでに登録されています"
        expect(find("#article_url").value).to eq url
        expect(UserArticle.count).to eq @user_articles_count
        expect(Article.count).to eq @articles_count
      end
    end
  end

  scenario "【URL】に登録したいURLを入力した状態で【あとで読む】ボタンを選択した場合、Articleモデルが作成され【あとで読むリストページ】の【あとで読むリスト】に登録したWeb記事が表示されること" do
    urls = [
      "https://qiita.com/at-946/items/a713a076d0bd9d887543",  # まだ登録されていないURL
      @user_articles[1][:rl].sample.article.url,              # 他のユーザーがあとで読むリストに登録しているURL
      @user_articles[1][:fr].sample.article.url               # 他のユーザーが読了リストに登録しているURL
    ]

    urls.each_with_index do |url, i|
      login(@users[0]) do
        visit articles_path(type: :reading_later)

        fill_in :article_url, with: url
        click_on :create_article_button

        expect(page).to have_current_path articles_path(type: :reading_later)
        expect(page).not_to have_selector "#error_message_area"
        expect(find("#article_url").value).to eq ""
        expect(find("#article_cards").all(".article-card")[-1].all("a")[0][:href]).to eq url
        expect(UserArticle.count).to eq @user_articles_count + (i + 1)
        expect(Article.count).to eq @articles_count + 1
      end
    end
  end

  scenario "【URL】にOGPが設定されていないページのURLを入力した状態で【あとで読む】ボタンを選択した場合、Articleモデルが作成され【あとで読むリストページ】に登録したWeb記事（タイトルがURL、OGPはNo Image）が表示されること" do
    url = "https://www.amazon.co.jp/dp/B0814STTHV/ref=dp-kindle-redirect?_encoding=UTF8&btkr=1"

    login(@users[0]) do
      visit articles_path(type: :reading_later)

      fill_in :article_url, with: url
      click_on :create_article_button

      expect(page).to have_current_path articles_path(type: :reading_later)
      expect(page).not_to have_selector "#error_message_area"
      expect(find("#article_url").value).to eq ""

      target_card = find("#article_cards").all(".article-card")[-1]
      expect(target_card.all("a")[0][:href]).to eq url
      expect(target_card.find(".card-header-title")).to have_text url
      expect(target_card.find(".card-image").find("img")[:src]).to include "no_image"
      expect(UserArticle.count).to eq @user_articles_count + 1
      expect(Article.count).to eq @articles_count + 1
    end
  end

  # 読了登録
  scenario "【記事】の【読了！】ボタンを選択した場合、【記事編集ページ】へ遷移すること" do
    login(@users[0]) do
      visit articles_path(type: :reading_later)
      article = find("#article_cards").all(".article-card")[0]
      article.find(".finish-reading-button").click
      expect(page).to have_current_path edit_article_path(@user_articles[0][:rl][0])
    end
  end

  # コメント編集
  scenario  "【記事】の【メモ編集】ボタンが存在しないこと" do
    login(@users[0]) do
      visit articles_path(type: :reading_later)
      find("#article_cards").all(".article-card").each do |article_card|
        expect(article_card).not_to have_selector ".edit-memo-button"
      end
    end
  end

  # SNSシェア
  scenario "【記事】の【Tweet】ボタンが存在しないこと" do
    login(@users[0]) do
      visit articles_path(type: :reading_later)
      find("#article_cards").all(".article-card").each do |article_card|
        expect(article_card).not_to have_selector ".article-tweet-button"
      end
    end
  end

  # 記事削除
  scenario "【記事】の【削除】ボタンを選択した場合、【削除確認ダイアログ】が表示されること" do
    login(@users[0]) do
      visit articles_path(type: :reading_later)

      page.dismiss_confirm("#{@user_articles[0][:rl][0].article.title}を削除しますか？") do
        all(".article-card")[0].find(".card-delete-button").click
      end
    end
  end

  scenario "【削除確認ダイアログ】で【キャンセル】を選択した場合、【記事】は削除されず【削除確認ダイアログ】が閉じること" do
    login(@users[0]) do
      visit articles_path(type: :reading_later)
      expect(all(".article-card")[0].all("a")[0][:href]).to eq @user_articles[0][:rl][0].article.url

      page.dismiss_confirm do
        all(".article-card")[0].find(".card-delete-button").click
      end

      expect(page).to have_current_path articles_path(type: :reading_later)
      expect(all(".article-card")[0].all("a")[0][:href]).to eq @user_articles[0][:rl][0].article.url
      expect(UserArticle.count).to eq @user_articles_count
      expect(Article.count).to eq @articles_count
    end
  end

  scenario "【削除確認ダイアログ】で【OK】を選択した場合、【記事】が削除され【削除確認ダイアログ】が閉じること" do
    # User1がUser1だけが登録している記事を削除した場合、ArticleがDBから削除される
    login(@users[0]) do
      visit articles_path(type: :reading_later)
      
      expect(all(".article-card").count).to eq @user_articles[0][:rl].count
      expect(all(".article-card")[0].all("a")[0][:href]).to eq @user_articles[0][:rl][0].article.url
      
      page.accept_confirm do
        all(".article-card")[0].find(".card-delete-button").click
      end
      
      expect(page).to have_current_path articles_path(type: :reading_later)
      expect(all(".article-card").count).to eq @user_articles[0][:rl].count - 1
      expect(all(".article-card")[0].all("a")[0][:href]).to eq @user_articles[0][:rl][1].article.url
      expect(UserArticle.count).to eq @user_articles_count - 1
      expect(Article.count).to eq @articles_count - 1
    end

    # User1がUser2のあとで読むリストに登録されている記事を削除した場合、ArticleはDBから削除されない
    type_article = [
      [:reading_later, :rl, @user_articles[1][:rl].sample.article],
      [:finish_reading, :fr, @user_articles[1][:fr].sample.article]
    ]

    type_article.each do |type, short_type, article|
      create(:user_article, user_id: @users[0].id, article_id: article.id)
      expect(UserArticle.count).to eq @user_articles_count
      expect(Article.count).to eq @articles_count - 1
      
      ## User2のあとで読むリスト（読了リスト）に記事が存在することを検証
      login(@users[1]) do
        visit articles_path(type: type)
        expect(all(".article-card").count).to eq @user_articles[1][short_type].count
        expect(page).to have_link nil, href: article.url
      end
      
      ## User1のあとで読むリストから記事を削除する
      login(@users[0]) do
        visit articles_path(type: :reading_later)
        expect(all(".article-card").count).to eq @user_articles[0][:rl].count
        expect(all(".article-card")[-1].all("a")[0][:href]).to eq article.url
        
        page.accept_confirm do
          all(".article-card")[-1].find(".card-delete-button").click
        end
        
        expect(page).to have_current_path articles_path(type: :reading_later)
        expect(all(".article-card").count).to eq @user_articles[0][:rl].count - 1
        expect(page).not_to have_link nil, href: article.url
        expect(UserArticle.count).to eq @user_articles_count - 1
        expect(Article.count).to eq @articles_count - 1
      end
      
      ## User2のあとで読むリスト（読了リスト）に記事が存在し続けていることを検証
      login(@users[1]) do
        visit articles_path(type: type)
        expect(all(".article-card").count).to eq @user_articles[1][short_type].count
        expect(page).to have_link nil, href: article.url
      end
    end
  end
end