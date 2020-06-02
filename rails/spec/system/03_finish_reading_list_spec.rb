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
    login do
      visit articles_path(type: :finish_reading)
      expect(page).to have_current_path articles_path(type: :finish_reading)
    end
  end

  # ログイン・ログアウト
  scenario "【ログイン】ボタンが表示されないこと" do
    login do
      visit articles_path(type: :finish_reading)
      expect(page).not_to have_selector "#login_button"
    end
  end

  scenario "【ログアウト】ボタンを選択した場合、【ログイン前】状態になり【トップページ】が表示されること" do
    login(logout: false) do
      visit articles_path(type: :finish_reading)
      click_on :logout_button
      expect(page).to have_current_path root_path
    end
  end

  # ページ遷移
  scenario "【あとで読む】タブを選択した場合、【あとで読むリストページ】へ遷移すること" do
    login(uid: @user1[:uid]) do
      visit articles_path(type: :finish_reading)
      click_on :reading_later_tab
      expect(page).to have_current_path articles_path(type: :reading_later)
    end
  end

  # コンテンツ表示
  scenario "ログインユーザーが読了した記事が読了日時降順で表示されていること" do
    @users.each do |user|
      login(uid: user[:uid]) do
        visit articles_path(type: :finish_reading)
        article_cards = find("#article_cards").all(".article-card")

        expect(article_cards.count).to eq user[:finish_reading_articles].count

        user[:finish_reading_articles].each_with_index do |article, i|
          # 記事を選択した場合、そのWeb記事のサイトに別タブで遷移すること
          expect(article_cards[i].all("a")[0][:href]).to eq user[:finish_reading_articles][i].url
          expect(article_cards[i].all("a")[0][:target]).to eq "_blank"
          # 記事のOGP画像が表示されること
          expect(article_cards[i].find(".card-image").find("img")[:src]).to eq user[:finish_reading_articles][i].image_url
          # 記事のタイトルが表示されること
          expect(article_cards[i].find(".card-header-title")).to have_text user[:finish_reading_articles][i].title
          # 記事のメモが登録されている場合、記事のメモが表示されること
          # 記事のメモが登録されていない場合、記事のメモが表示されないこと
          if article.memo.present?
            expect(article_cards[i].find(".article-memo")).to have_text user[:finish_reading_articles][i].memo
          else
            expect(article_cards[i]).not_to have_selector ".article-memo"
          end
        end
      end
    end
  end

  scenario "ログインユーザーが後から読む記事は表示されないこと" do
    @users.each do |user|
      login(uid: user[:uid]) do
        visit articles_path(type: :finish_reading)
        article_cards = find("#article_cards").all(".article-card")

        user[:reading_later_articles].each do |article|
          article_cards.each do |article_card|
            expect(article_card.all("a")[0][:href]).not_to eq article.url
          end
        end
      end
    end
  end

  scenario "ログインユーザー以外が読了した記事は表示されないこと" do
    @users.each do |user|
      login(uid: user[:uid]) do
        visit articles_path(type: :finish_reading)
        article_cards = find("#article_cards").all(".article-card")

        rest_users = @users.reject {|item| item == user}
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

  scenario "ログインユーザー以外が後から読む記事は表示されないこと" do
    @users.each do |user|
      login(uid: user[:uid]) do
        visit articles_path(type: :finish_reading)
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

  scenario "読了記事の数が表示されること" do
    @users.each do |user|
      login(uid: user[:uid]) do
        visit articles_path(type: :finish_reading)
        expect(page).to have_text "読了記事数：#{user[:finish_reading_articles].count}"
      end
    end
  end

  # 読了登録
  scenario "【記事】の【読了！】ボタンが存在しないこと" do
    login(uid: @user1[:uid]) do
      visit articles_path(type: :finish_reading)
      find("#article_cards").all(".article-card").each do |article_card|
        expect(article_card).not_to have_selector ".finish-reading-button"
      end
    end
  end

  ### コメント編集
  scenario "【記事】の【メモ編集】ボタンを選択した場合、【記事編集ページ】に遷移すること" do
    login(uid: @user1[:uid]) do
      visit articles_path(type: :finish_reading)
      find("#article_cards").all(".article-card")[0].find(".edit-memo-button").click
      expect(page).to have_current_path edit_article_path(@user1[:finish_reading_articles][0])
    end
  end

  # 記事削除
  scenario "【記事】の【削除】ボタンが存在しないこと" do
    login(uid: @user1[:uid]) do
      visit articles_path(type: :finish_reading)
      target = find("#article_cards").all(".article-card")[0]
      expect(target).not_to have_selector ".card-delete-button"
    end
  end
end