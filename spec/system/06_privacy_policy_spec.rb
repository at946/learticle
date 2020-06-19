feature "Privacy policy page", type: :system, js: true do
  background do
    @user = create(:user)
  end

  ### アクセス
  scenario "【ログイン前】に【/privacy_policy】にアクセスしようとした場合、【プライバシーポリシーページ】が表示されること" do
    visit pp_path
    expect(page).to have_current_path pp_path
  end

  scenario "【ログイン後】に【/privacy_policy】にアクセスしようとした場合、【プライバシーポリシーページ】が表示されること" do
    login(@user) do
      visit pp_path
      expect(page).to have_current_path pp_path
    end
  end

  ### ログイン・ログアウト
  scenario "【ログイン前】に【ヘッダー】の【ログイン】ボタンを選択した場合、【ログインページ】が表示されること" do
    visit pp_path

    login_button = find("#login_button")
    expect(login_button["href"]).to include "auth/auth0"
    expect(login_button["data-method"]).to eq "post"
    
    login_button.click
    expect(page).to have_current_path articles_path(type: :reading_later)
  end

  scenario "【ログイン前】に【ヘッダー】に【ログアウト】ボタンが表示されないこと" do
    visit pp_path
    expect(page).not_to have_selector "#logout_button"
  end

  scenario "【ログイン後】に【ヘッダー】に【ログイン】ボタンが表示されないこと" do
    login(@user) do
      visit pp_path
      expect(page).not_to have_selector "#login_button"
    end
  end

  scenario "【ログイン後】に【ヘッダー】の【ログアウト】ボタンを選択した場合、【ログイン前】状態になり【トップページ】が表示されること" do
    login(@user, logout: false) do
      visit pp_path
      click_on :logout_button
      expect(page).to have_current_path root_path
    end
  end

  ### ページ遷移
  scenario "【ログイン前】に【ヘッダー】の【ロゴ】を選択した場合、【トップページ】が表示されること" do
    visit pp_path
    click_on :logo
    expect(page).to have_current_path root_path
  end

  scenario "【ログイン後】に【ヘッダー】の【ロゴ】を選択した場合、【あとで読むページ】が表示されること" do
    login(@user) do
      visit pp_path
      click_on :logo
      expect(page).to have_current_path articles_path(type: :reading_later)
    end
  end

  scenario "【ログイン前】に【フッター】の【利用規約】リンクを選択した場合、【プライバシーポリシーページ】が表示されること" do
    visit pp_path
    click_on :tos_link
    expect(page).to have_current_path tos_path
  end

  scenario "【ログイン後】に【フッター】の【利用規約】リンクを選択した場合、【プライバシーポリシーページ】が表示されること" do
    login(@user) do
      visit pp_path
      click_on :tos_link
      expect(page).to have_current_path tos_path
    end
  end

  scenario "【ログイン前】に【フッター】の【プライバシーポリシー】リンクを選択できないこと" do
    visit pp_path
    expect(page).not_to have_selector "a#pp_link"
  end

  scenario "【ログイン後】に【フッター】の【プライバシーポリシー】リンクを選択できないこと" do
    login(@user) do
      visit pp_path
      expect(page).not_to have_selector "a#pp_link"
    end
  end

end