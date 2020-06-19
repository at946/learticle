feature "Top page", type: :system, js: true do
  scenario "【ログイン前】に【/】にアクセスしようとした場合、【トップページ】が表示されること" do
    visit root_path
    expect(page).to have_current_path root_path
  end

  scenario "【ログイン後】に【/】にアクセスしようとした場合、【あとで読むリストページ】にリダイレクトされること" do
    user = create(:user)
    login(user) do
      visit root_path
      expect(page).to have_current_path articles_path(type: :reading_later)
    end
  end

  scenario "ヘッダーの【ログイン】ボタンを選択した場合、【ログインページ】が表示されること" do
    visit root_path

    login_button = find("#login_button")
    expect(login_button["href"]).to include "auth/auth0"
    expect(login_button["data-method"]).to eq "post"
    
    login_button.click
    expect(page).to have_current_path articles_path(type: :reading_later)
  end

  scenario "【ログイン】ボタンを選択した場合、【ログインページ】が表示されること" do
    visit root_path

    login_button = find("#landing_login_button")
    expect(login_button["href"]).to include "auth/auth0"
    expect(login_button["data-method"]).to eq "post"

    login_button.click
    expect(page).to have_current_path articles_path(type: :reading_later)
  end

  scenario "【ログアウト】ボタンが表示されないこと" do
    visit root_path
    expect(page).not_to have_selector "#logout_button"
  end

  ### ページ遷移
  scenario "【ヘッダー】の【ロゴ】を選択した場合、【トップページ】が表示されること" do
    visit root_path
    click_on :logo
    expect(page).to have_current_path root_path
  end

  scenario "【フッター】の【利用規約】リンクを選択した場合、【利用ページ】が表示されること" do
    visit root_path
    click_on :tos_link
    expect(page).to have_current_path tos_path
  end

  scenario "【フッター】の【プライバシーポリシー】リンクを選択した場合、【プライバシーポリシーページ】が表示されること" do
    visit root_path
    click_on :pp_link
    expect(page).to have_current_path pp_path
  end

end