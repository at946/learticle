feature "Reading later list page", type: :system, js: true do
  background do
    @article1 = Article.create(url: "https://qiita.com/at-946/items/1e8acea19cc0b9f31b98")
    @article2 = Article.create(url: "https://note.com/at946/n/n1fd654316f31")
    @article3 = Article.create(url: "https://www.wantedly.com/users/128531805")
    @articles = [@article1, @article2, @article3]
  end

  scenario "【/】にアクセスしようとした場合、【あとで読むリストページ】が表示されること" do
    visit root_path
    expect(current_path).to eq root_path
  end

  scenario "【/articles】にアクセスしようとした場合、【あとで読むリストページ】が表示されること" do
    visit articles_path
    expect(current_path).to eq articles_path
  end

  scenario "登録されている記事の数だけArticleカードが登録日時降順で表示されていること" do
    visit articles_path
    # 表示されているArticleカードのリストを取得
    article_cards = find("#article_cards").all(".article-card")
    
    # 登録されているArticle数と表示されているArticleカード数が同一であることを検証する
    expect(article_cards.count).to eq @articles.count
    # 表示されているArticleカードが登録日時降順に並んでいることを検証
    @articles.each_with_index do |article, i|
      expect(article_cards[i].all("a")[0][:href]).to eq @articles[-(i+1)].url
    end
  end

  scenario "Articleカードを選択した場合、そのWeb記事のサイトに別タブで遷移すること" do
    visit articles_path
    article_cards = find("#article_cards").all(".article-card")

    @articles.each_with_index do |article, i|
      expect(article_cards[i].all("a")[0][:href]).to eq @articles[-(i+1)].url
      expect(article_cards[i].all("a")[0][:target]).to eq "_blank"
    end
  end

  scenario "【URL】が未入力の状態で【追加する】ボタンを選択した場合、Articleモデルは作成されず【あとで読むリストページ】で【URL未入力】のエラーメッセージが表示されること" do
    articles_count = Article.count
    visit articles_path
    
    fill_in :article_url, with: ""
    click_on :create_article_button

    expect(Article.count).to eq articles_count
    expect(current_path).to eq articles_path
    expect(page).to have_text "URLに https:// または http:// から始まる文字列を入力してください"
  end

  scenario "【URL】にURLフォーマット以外（http:// or https:// 以外）文字列を入力した状態で【追加する】ボタンを選択した場合、Articleモデルは作成されず【あとで読むリストページ】で【URLフォーマットエラー】のエラーメッセージが表示されること" do
    articles_count = Article.count
    visit articles_path
    
    fill_in :article_url, with: "ftp://bad_uri.com"
    click_on :create_article_button

    expect(Article.count).to eq articles_count
    expect(current_path).to eq articles_path
    expect(page).to have_text "URLに https:// または http:// から始まる文字列を入力してください"
  end

  scenario "【URL】に2001文字以上の文字列を入力した状態で【追加する】ボタンを選択した場合、Articleモデルは作成されず【あとで読むリストページ】で【URL文字数超過】のエラーメッセージが表示されること" do
    articles_count = Article.count
    visit articles_path

    fill_in :article_url, with: "https://" + "a" * 1993
    click_on :create_article_button
    
    expect(Article.count).to eq articles_count
    expect(current_path).to eq articles_path
    expect(page).to have_text "URLは2000文字以内で入力してください"
  end

  scenario "【URL】に登録したいURLを入力した状態で【追加する】ボタンを選択した場合、Articleモデルが作成され【あとで読むリストページ】の【あとで読むリスト】に登録したWeb記事が表示されること" do
    urls = ["http://a", "https://" + "a" * 1992, "https://google.com"]
    visit articles_path

    urls.each do |url|
      articles_count = Article.count
      fill_in :article_url, with: url
      click_on :create_article_button

      expect(Article.count).to eq articles_count + 1
      expect(current_path).to eq articles_path
      expect(page).not_to have_selector "#error_message_area"
    end
  end

end