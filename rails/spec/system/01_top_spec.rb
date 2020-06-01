feature "Top page", type: :system, js: true do
  scenario "【ログイン前】に【/】にアクセスしようとした場合、【トップページ】が表示されること" do
    visit root_path
    expect(page).to have_current_path root_path
  end

  scenario "【ログイン後】に【/】にアクセスしようとした場合、【あとで読むリストページ】にリダイレクトされること" do
    login do
      visit root_path
      expect(page).to have_current_path articles_path(type: :reading_later)
    end
  end

  scenario "【ログイン】ボタンを選択した場合、【ログインページ】が表示されること" do
    visit root_path

    login_button = find("#login_button")
    expect(login_button["href"]).to include "auth/auth0"
    expect(login_button["data-method"]).to eq "post"
    
    login_button.click
    expect(page).to have_current_path articles_path(type: :reading_later)
  end

  scenario "【ログアウト】ボタンが表示されないこと" do
    visit root_path
    expect(page).not_to have_selector "#logout_button"
  end

end