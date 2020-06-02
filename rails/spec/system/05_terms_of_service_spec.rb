feature "Terms of service page", type: :system, js: true do  
  ### アクセス
  scenario "【ログイン前】に【/terms_of_service】にアクセスしようとした場合、【利用規約ページ】が表示されること" do
    visit tos_path
    expect(page).to have_current_path tos_path
  end

  scenario "【ログイン後】に【/terms_of_service】にアクセスしようとした場合、【利用規約ページ】が表示されること" do
    login do
      visit tos_path
      expect(page).to have_current_path tos_path
    end
  end

  ### ログイン・ログアウト
  scenario "【ログイン前】に【ヘッダー】の【ログイン】ボタンを選択した場合、【ログインページ】が表示されること" do
    visit tos_path

    login_button = find("#login_button")
    expect(login_button["href"]).to include "auth/auth0"
    expect(login_button["data-method"]).to eq "post"
    
    login_button.click
    expect(page).to have_current_path articles_path(type: :reading_later)
  end

  scenario "【ログイン前】に【ヘッダー】に【ログアウト】ボタンが表示されないこと" do
    visit tos_path
    expect(page).not_to have_selector "#logout_button"
  end

  scenario "【ログイン後】に【ヘッダー】に【ログイン】ボタンが表示されないこと" do
    login do
      visit tos_path
      expect(page).not_to have_selector "#login_button"
    end
  end

  scenario "【ログイン後】に【ヘッダー】の【ログアウト】ボタンを選択した場合、【ログイン前】状態になり【トップページ】が表示されること" do
    login(logout: false) do
      visit tos_path
      click_on :logout_button
      expect(page).to have_current_path root_path
    end
  end

  ### ページ遷移
  scenario "【ログイン前】に【ヘッダー】の【ロゴ】を選択した場合、【トップページ】が表示されること" do
    visit tos_path
    click_on :logo
    expect(page).to have_current_path root_path
  end

  scenario "【ログイン後】に【ヘッダー】の【ロゴ】を選択した場合、【あとで読むページ】が表示されること" do
    login do
      visit tos_path
      click_on :logo
      expect(page).to have_current_path articles_path(type: :reading_later)
    end
  end

  scenario "【ログイン前】に【フッター】の【利用規約】リンクを選択できないこと" do
    visit tos_path
    expect(page).not_to have_selector "a#tos_link"
  end

  scenario "【ログイン後】に【フッター】の【利用規約】リンクを選択できないこと" do
    login do
      visit tos_path
      expect(page).not_to have_selector "a#tos_link"
    end
  end

  scenario "【ログイン前】に【フッター】の【プライバシーポリシー】リンクを選択した場合、【プライバシーポリシーページ】が表示されること" do
    visit tos_path
    click_on :pp_link
    expect(page).to have_current_path pp_path
  end

  scenario "【ログイン後】に【フッター】の【プライバシーポリシー】リンクを選択した場合、【プライバシーポリシーページ】が表示されること" do
    login do
      visit tos_path
      click_on :pp_link
      expect(page).to have_current_path pp_path
    end
  end

end