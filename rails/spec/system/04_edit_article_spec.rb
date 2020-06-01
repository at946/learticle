feature "Edit article page", type: :system, js: true do
  background do
    user_prepare
  end

  # アクセス
  scenario "【ログイン前】に【/articles/:id/edit】にアクセスしようとした場合、【トップページ】にリダイレクトすること" do
    visit edit_article_path(@user1[:reading_later_articles].first)
    expect(page).to have_current_path root_path
  end

  scenario "【ログイン後】に【ログインユーザーのあとで読む記事】に対して【/articles/:id/edit】にアクセスしようとした場合、【読了登録ページ】が表示されること" do
    @users.each do |user|
      login(uid: user[:uid]) do
        user[:reading_later_articles].each do |article|
          visit edit_article_path(article)
          expect(page).to have_current_path edit_article_path(article)
        end
      end
    end
  end

  scenario "【ログイン後】に【ログインユーザーの読了記事】に対して【/articles/:id/edit】にアクセスしようとした場合、【あとで読むリストページ】にリダイレクトすること" do
    @users.each do |user|
      login(uid: user[:uid]) do
        user[:finish_reading_articles].each do |article|
          visit edit_article_path(article)
          expect(page).to have_current_path articles_path(type: :reading_later)
        end
      end
    end
  end

  scenario "【ログイン後】に【ログインユーザー以外のあとで読む記事】に対して【/articles/:id/edit】にアクセスしようとした場合、【あとで読むリストページ】にリダイレクトすること" do
    @users.each do |user|
      login(uid: user[:uid]) do
        rest_users = @users.reject {|item| item == user}
        rest_users.each do |rest_user|
          rest_user[:reading_later_articles].each do |article|
            visit edit_article_path(article)
            expect(page).to have_current_path articles_path(type: :reading_later)
          end
        end
      end
    end
  end

  scenario "【ログイン後】に【ログインユーザー以外の読了記事】に対して【/articles/:id/edit】にアクセスしようとした場合、【あとで読むリストページ】にリダイレクトすること" do
    @users.each do |user|
      login(uid: user[:uid]) do
        rest_users =  @users.reject {|item| item == user}
        rest_users.each do |rest_user|
          rest_user[:finish_reading_articles].each do |article|
            visit edit_article_path(article)
            expect(page).to have_current_path articles_path(type: :reading_later)
          end
        end
      end
    end
  end

  scenario "【ログイン後】に【存在しない記事ID】に対して【/articles/:id/edit】にアクセスしようとした場合、【あとで読むリストページ】にリダイレクトすること" do
    login do
      visit edit_article_path(0)
      expect(page).to have_current_path articles_path(type: :reading_later)
    end
  end

  # ログイン・ログアウト
  scenario "【ログイン】ボタンが表示されないこと" do
    login(uid: @user1[:uid]) do
      visit edit_article_path(@user1[:reading_later_articles][0])
      expect(page).to have_current_path  edit_article_path(@user1[:reading_later_articles][0])
    end
  end

  scenario "【ログアウト】ボタンを選択した場合、【ログイン前】状態になり【トップページ】が表示されること" do
    login(uid: @user1[:uid], logout: false) do
      visit edit_article_path(@user1[:reading_later_articles][0])
      click_on :logout_button
      expect(page).to have_current_path root_path
    end
  end

  # ページ遷移
  scenario "【キャンセル】リンクを選択した場合、【あとで読むリストページ】へ遷移すること" do
    login(uid: @user1[:uid]) do
      visit articles_path(type: :reading_later)
      expect(find("#article_cards").all(".article-card")[0].all("a")[0][:href]).to eq @user1[:reading_later_articles][0].url

      visit edit_article_path(@user1[:reading_later_articles][0])
      click_on :cancel_link
      expect(page).to have_current_path articles_path(type: :reading_later)
      expect(find("#article_cards").all(".article-card")[0].all("a")[0][:href]).to eq @user1[:reading_later_articles][0].url
    end
  end

  # 読了登録
  scenario "【メモ】を未入力の状態で【読了！】ボタンを選択した場合、記事を読了リストに移動できること" do
    login(uid: @user1[:uid]) do
      target_article = @user1[:reading_later_articles][0]
      
      # ターゲットの記事があとで読むリストに存在することを検証
      visit articles_path(type: :reading_later)
      expect(find("#article_cards").all(".article-card")[0].all("a")[0][:href]).to eq target_article.url

      # ターゲットの記事が読了リストに存在しないことを検証
      visit articles_path(type: :finish_reading)
      expect(find("#article_cards").all(".article-card")[0].all("a")[0][:href]).not_to eq target_article.url

      # メモ未入力で読了登録
      visit edit_article_path(target_article)
      fill_in :article_memo, with: ""
      click_on :finish_reading_button

      # ターゲットの記事があとで読むリストに存在しないことを検証
      expect(page).to have_current_path articles_path(type: :reading_later)
      expect(find("#article_cards").all(".article-card")[0].all("a")[0][:href]).not_to eq target_article.url

      # ターゲットの記事が読了リストに存在することを検証
      visit articles_path(type: :finish_reading)
      expect(find("#article_cards").all(".article-card")[0].all("a")[0][:href]).to eq target_article.url
    end
  end

  scenario "【メモ】を1001文字以上の状態で【読了！】ボタンを選択した場合、記事は読了リストに移動せず【文字数超過】のエラーメッセージが表示されること" do
    login(uid: @user1[:uid]) do
      target_article = @user1[:reading_later_articles][0]
      
      # ターゲットの記事があとで読むリストに存在することを検証
      visit articles_path(type: :reading_later)
      expect(find("#article_cards").all(".article-card")[0].all("a")[0][:href]).to eq target_article.url

      # ターゲットの記事が読了リストに存在しないことを検証
      visit articles_path(type: :finish_reading)
      expect(find("#article_cards").all(".article-card")[0].all("a")[0][:href]).not_to eq target_article.url

      # メモ未入力で読了登録
      visit edit_article_path(target_article)
      fill_in :article_memo, with: "a" * 1001
      click_on :finish_reading_button

      # エラーが発生することを検証
      expect(page).to have_current_path edit_article_path(target_article)
      expect(page).to have_text "メモは1000文字以内で入力してください"

      # ターゲットの記事があとで読むリストに存在することを検証
      visit articles_path(type: :reading_later)
      expect(find("#article_cards").all(".article-card")[0].all("a")[0][:href]).to eq target_article.url

      # ターゲットの記事が読了リストに存在しないことを検証
      visit articles_path(type: :finish_reading)
      expect(find("#article_cards").all(".article-card")[0].all("a")[0][:href]).not_to eq target_article.url
    end
  end

  [
    "Hello world.",
    "Hello world.\nThis is my impression sentence.",
    "a" * 1000
  ].each do |memo|
    scenario "【メモ】を入力した状態で【読了！】ボタンを選択した場合、記事は読了リストに移動できること" do

      login(uid: @user1[:uid]) do
        target_article = @user1[:reading_later_articles][0]
        
        # ターゲットの記事があとで読むリストに存在することを検証
        visit articles_path(type: :reading_later)
        expect(find("#article_cards").all(".article-card")[0].all("a")[0][:href]).to eq target_article.url

        # ターゲットの記事が読了リストに存在しないことを検証
        visit articles_path(type: :finish_reading)
        expect(find("#article_cards").all(".article-card")[0].all("a")[0][:href]).not_to eq target_article.url

        # メモ未入力で読了登録
        visit edit_article_path(target_article)
        fill_in :article_memo, with: memo
        click_on :finish_reading_button

        # ターゲットの記事があとで読むリストに存在しないことを検証
        expect(page).to have_current_path articles_path(type: :reading_later)
        expect(find("#article_cards").all(".article-card")[0].all("a")[0][:href]).not_to eq target_article.url

        # ターゲットの記事が読了リストに存在することを検証
        visit articles_path(type: :finish_reading)
        expect(find("#article_cards").all(".article-card")[0].all("a")[0][:href]).to eq target_article.url
      end
    end
  end

end