feature "Edit article page", type: :system, js: true do
  background do
    user_prepare
  end

  # アクセス
  scenario "【ログイン前】に【/articles/:id/edit】にアクセスしようとした場合、【トップページ】にリダイレクトすること" do
    visit edit_article_path(@user_articles[0][:rl][0])
    expect(page).to have_current_path root_path
  end

  scenario "【ログイン後】に【ログインユーザーのあとで読む記事】に対して【/articles/:id/edit】にアクセスしようとした場合、【記事編集ページ】が表示されること" do
    @users.each_with_index do |user, i|
      login(user) do
        @user_articles[i][:rl].each do |user_article|
          visit edit_article_path(user_article)
          expect(page).to have_current_path edit_article_path(user_article)
        end
      end
    end
  end

  scenario "【ログイン後】に【ログインユーザーの読了記事】に対して【/articles/:id/edit】にアクセスしようとした場合、【記事編集ページ】が表示されること" do
    @users.each_with_index do |user, i|
      login(user) do
        @user_articles[i][:fr].each do |user_article|
          visit edit_article_path(user_article)
          expect(page).to have_current_path edit_article_path(user_article)
        end
      end
    end
  end

  scenario "【ログイン後】に【ログインユーザー以外のあとで読む記事】に対して【/articles/:id/edit】にアクセスしようとした場合、【あとで読むリストページ】にリダイレクトすること" do
    @users.each do |user|
      login(user) do
        @users.each_with_index do |rest_user, i|
          unless rest_user == user
            @user_articles[i][:rl].each do |user_article|
              visit edit_article_path(user_article)
              expect(page).to have_current_path articles_path(type: :reading_later)
            end
          end
        end
      end
    end
  end

  scenario "【ログイン後】に【ログインユーザー以外の読了記事】に対して【/articles/:id/edit】にアクセスしようとした場合、【あとで読むリストページ】にリダイレクトすること" do
    @users.each do |user|
      login(user) do
        @users.each_with_index do |rest_user, i|
          unless rest_user == user 
            @user_articles[i][:fr].each do |user_article|
              visit edit_article_path(user_article)
              expect(page).to have_current_path articles_path(type: :reading_later)
            end
          end
        end
      end
    end
  end

  scenario "【ログイン後】に【存在しない記事ID】に対して【/articles/:id/edit】にアクセスしようとした場合、【あとで読むリストページ】にリダイレクトすること" do
    login(@users[0]) do
      visit edit_article_path(0)
      expect(page).to have_current_path articles_path(type: :reading_later)
    end
  end

  # ログイン・ログアウト
  scenario "【ログイン】ボタンが表示されないこと" do
    login(@users[0]) do
      visit edit_article_path(@user_articles[0][:rl][0])
      expect(page).to have_current_path  edit_article_path(@user_articles[0][:rl][0])
    end
  end

  scenario "【ログアウト】ボタンを選択した場合、【ログイン前】状態になり【トップページ】が表示されること" do
    login(@users[0], logout: false) do
      visit edit_article_path(@user_articles[0][:rl][0])
      click_on :logout_button
      expect(page).to have_current_path root_path
    end
  end

  # ページ遷移
  scenario "【ヘッダー】の【ロゴ】を選択した場合、【あとで読むリストページ】が表示されること" do
    login(@users[0]) do
      visit edit_article_path(@user_articles[0][:rl][0])
      click_on :logo
      expect(page).to have_current_path articles_path(type: :reading_later)
    end
  end

  scenario "【フッター】の【利用規約】リンクを選択した場合、【利用規約ページ】が表示されること" do
    login(@users[0]) do
      visit edit_article_path(@user_articles[0][:rl][0])
      click_on :tos_link
      expect(page).to have_current_path tos_path
    end
  end

  scenario "【フッター】の【プライバシーポリシー】リンクを選択した場合、【プライバシーポリシーページ】が表示されること" do
    login(@users[0]) do
      visit edit_article_path(@user_articles[0][:rl][0])
      click_on :pp_link
      expect(page).to have_current_path pp_path
    end
  end

  scenario "【あとで読むリスト】の記事を読了しようとしてページ遷移してきたあとで、【キャンセル】リンクを選択した場合、【あとで読むリストページ】へ遷移すること" do
    login(@users[0]) do
      visit edit_article_path(@user_articles[0][:rl][0])
      click_on :cancel_link
      
      expect(page).to have_current_path articles_path(type: :reading_later)
      @user_articles[0][:rl].each_with_index do |user_article, i|
        expect(find("#article_cards").all(".article-card")[i].all("a")[0][:href]).to eq user_article.article.url
      end

      visit articles_path(type: :finish_reading)
      @user_articles[0][:fr].each_with_index do |user_article, i|
        expect(find("#article_cards").all(".article-card")[i].all("a")[0][:href]).to eq user_article.article.url
      end      
    end
  end

  scenario "【読了リスト】の記事のメモを更新しようとしてページ遷移してきたあとで、【キャンセル】リンクを選択した場合、【読了リストページ】へ遷移すること" do
    login(@users[0]) do
      visit edit_article_path(@user_articles[0][:fr][0])
      click_on :cancel_link
      
      expect(page).to have_current_path articles_path(type: :finish_reading)
      @user_articles[0][:fr].each_with_index do |user_article, i|
        expect(find("#article_cards").all(".article-card")[i].all("a")[0][:href]).to eq user_article.article.url
      end

      visit articles_path(type: :reading_later)
      @user_articles[0][:rl].each_with_index do |user_article, i|
        expect(find("#article_cards").all(".article-card")[i].all("a")[0][:href]).to eq user_article.article.url
      end
    end
  end

  # 読了登録
  scenario "【あとで読むリストの記事】に対して【メモ】を未入力の状態で【読了！】ボタンを選択した場合、記事が読了リストに移動し、【あとで読むリストページ】に遷移すること" do
    login(@users[0]) do
      user_article = @user_articles[0][:rl][0]
      target_article = @user_articles[0][:rl][0].article
      
      # ターゲットの記事があとで読むリストに存在することを検証
      visit articles_path(type: :reading_later)
      expect(find("#article_cards").all(".article-card")[0].all("a")[0][:href]).to eq target_article.url

      # ターゲットの記事が読了リストに存在しないことを検証
      visit articles_path(type: :finish_reading)
      expect(find("#article_cards").all(".article-card")[0].all("a")[0][:href]).not_to eq target_article.url

      # メモ未入力で読了登録
      visit edit_article_path(user_article)
      fill_in :user_article_memo, with: ""
      click_on :update_article_button

      # ターゲットの記事があとで読むリストに存在しないことを検証
      expect(page).to have_current_path articles_path(type: :reading_later)
      expect(find("#article_cards").all(".article-card")[0].all("a")[0][:href]).not_to eq target_article.url

      # ターゲットの記事が読了リストに存在することを検証
      visit articles_path(type: :finish_reading)
      expect(find("#article_cards").all(".article-card")[0].all("a")[0][:href]).to eq target_article.url
      expect(find("#article_cards").all(".article-card")[0]).not_to have_selector ".article-memo"
    end
  end

  scenario "【あとで読むリストの記事】に対して【メモ】を1001文字以上の状態で【読了！】ボタンを選択した場合、記事は読了リストに移動せず【文字数超過】のエラーメッセージが表示されること" do
    login(@users[0]) do
      user_article = @user_articles[0][:rl][0]
      target_article = user_article.article
      
      # ターゲットの記事があとで読むリストに存在することを検証
      visit articles_path(type: :reading_later)
      expect(find("#article_cards").all(".article-card")[0].all("a")[0][:href]).to eq target_article.url

      # ターゲットの記事が読了リストに存在しないことを検証
      visit articles_path(type: :finish_reading)
      find("#article_cards").all(".article-card").each do |article_card|
        expect(article_card.all("a")[0][:href]).not_to eq target_article.url
      end

      # メモ1001文字以上で読了登録
      visit edit_article_path(user_article)
      fill_in :user_article_memo, with: Faker::Alphanumeric.alphanumeric(number: 1001)
      click_on :update_article_button

      # エラーが発生することを検証
      expect(page).to have_current_path edit_article_path(user_article)
      expect(page).to have_text "メモは1000文字以内で入力してください"

      # ターゲットの記事があとで読むリストに存在することを検証
      visit articles_path(type: :reading_later)
      expect(find("#article_cards").all(".article-card")[0].all("a")[0][:href]).to eq target_article.url

      # ターゲットの記事が読了リストに存在しないことを検証
      visit articles_path(type: :finish_reading)
      find("#article_cards").all(".article-card").each do |article_card|
        expect(article_card.all("a")[0][:href]).not_to eq target_article.url
      end
    end
  end

  [
    "Hello world.",
    "Hello world.\nThis is my impression sentence.",
    "a" * 1000
  ].each do |memo|
    scenario "【あとで読むリストの記事】に対して【メモ】を入力した状態で【読了！】ボタンを選択した場合、記事は読了リストに移動し、【あとで読むリストページ】に遷移すること" do

      login(@users[0]) do
        user_article = @user_articles[0][:rl][0]
        target_article = user_article.article
        
        # ターゲットの記事があとで読むリストに存在することを検証
        visit articles_path(type: :reading_later)
        expect(find("#article_cards").all(".article-card")[0].all("a")[0][:href]).to eq target_article.url

        # ターゲットの記事が読了リストに存在しないことを検証
        visit articles_path(type: :finish_reading)
        find("#article_cards").all(".article-card").each do |article_card|
          expect(article_card.all("a")[0][:href]).not_to eq target_article.url
        end

        # メモ未入力で読了登録
        visit edit_article_path(user_article)
        fill_in :user_article_memo, with: memo
        click_on :update_article_button

        # ターゲットの記事があとで読むリストに存在しないことを検証
        expect(page).to have_current_path articles_path(type: :reading_later)
        find("#article_cards").all(".article-card").each do |article_card|
          expect(article_card.all("a")[0][:href]).not_to eq target_article.url
        end

        # ターゲットの記事が読了リストに存在することを検証
        visit articles_path(type: :finish_reading)
        expect(find("#article_cards").all(".article-card")[0].all("a")[0][:href]).to eq target_article.url
        expect(find("#article_cards").all(".article-card")[0].find(".article-memo")).to have_text memo
      end
    end
  end

  # メモ更新
  scenario "【読了リストの記事】に対して【メモ】を未入力の状態で【読了！】ボタンを選択した場合、記事のメモが更新され、【読了リストページ】へ遷移すること" do
    login(@users[0]) do
      user_article = @user_articles[0][:fr][0]
      target_article = user_article.article
      memo_before = user_article.memo.to_s
      memo_after = ""
      
      # ターゲットの記事が読了リストに存在することを検証
      visit articles_path(type: :finish_reading)
      expect(find("#article_cards").all(".article-card")[0].all("a")[0][:href]).to eq target_article.url

      # ターゲットの記事があとで読むリストに存在しないことを検証
      visit articles_path(type: :reading_later)
      find("#article_cards").all(".article-card").each do |article_card|
        expect(article_card.all("a")[0][:href]).not_to eq target_article.url
      end

      # メモ未入力で読了登録
      visit edit_article_path(user_article)
      expect(find("#user_article_memo").value).to eq memo_before
      fill_in :user_article_memo, with: memo_after
      click_on :update_article_button

      # ターゲットの記事が読了リストに存在しメモが更新されていることを検証
      expect(page).to have_current_path articles_path(type: :finish_reading)
      expect(find("#article_cards").all(".article-card")[0].all("a")[0][:href]).to eq target_article.url
      expect(find("#article_cards").all(".article-card")[0]).not_to have_selector ".article-memo"

      # ターゲットの記事があとで読むリストに存在しないことを検証
      visit articles_path(type: :reading_later)
      find("#article_cards").all(".article-card").each do |article_card|
        expect(article_card.all("a")[0][:href]).not_to eq target_article.url
      end
    end
  end

  scenario "【読了リストの記事】に対して【メモ】を1001文字以上の状態で【読了！】ボタンを選択した場合、記事のメモは更新されず、【文字数超過】のエラーメッセージが表示されること" do
    login(@users[0]) do
      user_article = @user_articles[0][:fr][0]
      target_article = user_article.article
      memo_before = user_article.memo.to_s
      memo_after = Faker::Alphanumeric.alphanumeric(number: 1001)
      
      # ターゲットの記事が読了リストに存在することを検証
      visit articles_path(type: :finish_reading)
      expect(find("#article_cards").all(".article-card")[0].all("a")[0][:href]).to eq target_article.url

      # ターゲットの記事が読了リストに存在しないことを検証
      visit articles_path(type: :reading_later)
      find("#article_cards").all(".article-card").each do |article_card|
        expect(article_card.all("a")[0][:href]).not_to eq target_article.url
      end

      # メモ未入力で読了登録
      visit edit_article_path(user_article)
      expect(find("#user_article_memo").value).to eq memo_before
      fill_in :user_article_memo, with: "a" * 1001
      click_on :update_article_button

      # エラーが発生することを検証
      expect(page).to have_current_path edit_article_path(user_article)
      expect(page).to have_text "メモは1000文字以内で入力してください"

      # ターゲットの記事が読了リストに存在してメモが更新されていないことを検証
      visit articles_path(type: :finish_reading)
      target_card = find("#article_cards").all(".article-card")[0]
      expect(target_card.all("a")[0][:href]).to eq target_article.url
      if memo_before.present?
        expect(target_card.find(".article-memo")).to have_text memo_before
        expect(target_card.find(".article-memo")).not_to have_text memo_after
      else
        expect(target_card).not_to have_selector ".article-memo"
      end

      # ターゲットの記事があとで読むリストに存在しないことを検証
      visit articles_path(type: :reading_later)
      find("#article_cards").all(".article-card").each do |article_card|
        expect(article_card.all("a")[0][:href]).not_to eq target_article.url
      end
    end
  end

  [
    "Hello world.",
    "Hello world.\nThis is my impression sentence.",
    "a" * 1000
  ].each do |memo|
    scenario "【読了リストの記事】に対して【メモ】を入力した状態で【読了！】ボタンを選択した場合、記事のメモが更新され、【読了リストページ】へ遷移すること" do

      login(@users[0]) do
        user_article = @user_articles[0][:fr][0]
        target_article = user_article.article
        memo_before = user_article.memo.to_s
        
        # ターゲットの記事が読了リストに存在することを検証
        visit articles_path(type: :finish_reading)
        expect(find("#article_cards").all(".article-card")[0].all("a")[0][:href]).to eq target_article.url

        # ターゲットの記事があとで読むリストに存在しないことを検証
        visit articles_path(type: :reading_later)
        find("#article_cards").all(".article-card").each do |article_card|
          expect(article_card.all("a")[0][:href]).not_to eq target_article.url
        end

        # メモ未入力で読了登録
        visit edit_article_path(user_article)
        expect(find("#user_article_memo").value).to eq memo_before
        fill_in :user_article_memo, with: memo
        click_on :update_article_button

        # ターゲットの記事のメモが更新されて読了リストに存在することを検証
        expect(page).to have_current_path articles_path(type: :finish_reading)
        target_card = find("#article_cards").all(".article-card")[0]
        expect(target_card.all("a")[0][:href]).to eq target_article.url
        expect(target_card.find(".article-memo")).to have_text memo

        # ターゲットの記事があとで読むに存在しないことを検証
        visit articles_path(type: :reading_later)
        find("#article_cards").all(".article-card").each do |target_card|
          expect(target_card.all("a")[0][:href]).not_to eq target_article.url
        end
      end
    end
  end

  ### SNSシェア
  scenario "【Tweet】ボタンを選択した場合、【ツイートページ】に遷移すること" do
    login(@users[0]) do
      [@user_articles[0][:rl][0], @user_articles[0][:fr][0]].each do |user_article|
        article = user_article.article
        ["#{Faker::Hipster.sentence}\n#{Faker::Hipster.sentence}", ""].each do |memo|
          visit edit_article_path(user_article)
          fill_in :user_article_memo, with: memo
          click_on :tweet_button
          switch_to_window(windows.last)
          url = CGI.unescape(current_url)
          expect(url).to include "https://twitter.com/intent/tweet"
          # 【ツイートページ】の【テキストエリア】に【記事】の入力中の【メモ】が入力されていること
          expect(url).not_to include article.to_s if user_article.memo.present?
          if memo.present?
            expect(url).to include memo
            expect(url).not_to include "読みました！"
          else
            expect(url).to include "読みました！"
          end
          # 【ツイートページ】の【テキストエリア】に【記事】の【URL】が入力されていること
          expect(url).to include article.url
          # 【ツイートページ】の【テキストエリア】に【#Learticle】のハッシュタグが入力されていること
          expect(url).to include "#Learticle"
          current_window.close
          switch_to_window(windows.first)
        end
      end
    end
  end

end