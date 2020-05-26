feature "Reading later list page", type: :system, js: true do
  background do
    @articles = []
    @articles.prepend(Article.create(url: "https://qiita.com/at-946/items/1e8acea19cc0b9f31b98"))
    @articles.prepend(Article.create(url: "https://note.com/at946/n/n1fd654316f31"))
    @articles.prepend(Article.create(url: "https://www.wantedly.com/users/128531805"))
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
      expect(article_cards[i].all("a")[0][:href]).to eq @articles[i].url
    end
  end

  scenario "Articleカードを選択した場合、そのWeb記事のサイトに別タブで遷移すること" do
    visit articles_path
    article_cards = find("#article_cards").all(".article-card")

    @articles.each_with_index do |article, i|
      expect(article_cards[i].all("a")[0][:href]).to eq @articles[i].url
      expect(article_cards[i].all("a")[0][:target]).to eq "_blank"
    end
  end

  scenario "ArticleカードにサイトのOGPが表示されること" do
    visit articles_path
    article_cards = find("#article_cards").all(".article-card")

    @articles.each_with_index do |article, i|
      expect(article_cards[i].find(".card-image").find("img")[:src]).to eq @articles[i].image_url
    end
  end

  scenario "Articleカードにサイトのタイトルが表示されること" do
    visit articles_path
    article_cards = find("#article_cards").all(".article-card")

    @articles.each_with_index do |article, i|
      expect(article_cards[i].find(".card-header-title")).to have_text @articles[i].title
    end
  end

  scenario "Articleカードにサイトの登録日が表示されること" do
    visit articles_path
    article_cards = find("#article_cards").all(".article-card")

    @articles.each_with_index do |article, i|
      expect(article_cards[i].find(".card-content").find(".article-registered-at")).to have_text @articles[i].created_at.strftime("%Y.%m.%d")
    end
  end

  scenario "【URL】が未入力の状態で【追加する】ボタンを選択した場合、Articleモデルは作成されず【あとで読むリストページ】で【URL未入力】のエラーメッセージが表示されること" do
    articles_count = Article.count
    visit articles_path
    
    fill_in :article_url, with: ""
    click_on :create_article_button

    expect(current_path).to eq articles_path
    expect(page).to have_text "URLに https:// または http:// から始まる文字列を入力してください"
    expect(Article.count).to eq articles_count
  end

  scenario "【URL】にURLフォーマット以外（http:// or https:// 以外）文字列を入力した状態で【追加する】ボタンを選択した場合、Articleモデルは作成されず【あとで読むリストページ】で【URLフォーマットエラー】のエラーメッセージが表示されること" do
    articles_count = Article.count
    visit articles_path
    
    fill_in :article_url, with: "ftp://bad_uri.com"
    click_on :create_article_button

    expect(current_path).to eq articles_path
    expect(page).to have_text "URLに https:// または http:// から始まる文字列を入力してください"
    expect(Article.count).to eq articles_count
  end

  scenario "【URL】に2001文字以上の文字列を入力した状態で【追加する】ボタンを選択した場合、Articleモデルは作成されず【あとで読むリストページ】で【URL文字数超過】のエラーメッセージが表示されること" do
    articles_count = Article.count
    visit articles_path

    fill_in :article_url, with: "https://" + "a" * 1993
    click_on :create_article_button
    
    expect(current_path).to eq articles_path
    expect(page).to have_text "URLは2000文字以内で入力してください"
    expect(Article.count).to eq articles_count
  end

  scenario "【URL】に存在しないURLを入力した状態で【追加する】ボタンを選択した場合、Articleモデルは作成されず【あとで読むリストページ】で【存在しないページ】のエラーメッセージが表示されること" do
    articles_count = Article.count
    visit articles_path

    fill_in :article_url, with: "http://a"
    click_on :create_article_button

    expect(current_path).to eq articles_path
    expect(page).to have_text "URLのページは存在しないようです"
    expect(Article.count).to eq articles_count
  end

  scenario "【URL】に登録したいURLを入力した状態で【追加する】ボタンを選択した場合、Articleモデルが作成され【あとで読むリストページ】の【あとで読むリスト】に登録したWeb記事が表示されること" do
    url = "https://qiita.com/at-946/items/08de3c9d7611f62b1894"
    visit articles_path

    articles_count = Article.count
    fill_in :article_url, with: url
    click_on :create_article_button

    expect(current_path).to eq articles_path
    expect(page).not_to have_selector "#error_message_area"
    expect(Article.count).to eq articles_count + 1
  end

  scenario "【URL】にOGPが設定されていないページのURLを入力した状態で【追加する】ボタンを選択した場合、Articleモデルが作成され【あとで読むリストページ】に登録したWeb記事（タイトルがURL、OGPはNo Image）が表示されること" do
    url = "https://www.amazon.co.jp/dp/B0814STTHV/ref=dp-kindle-redirect?_encoding=UTF8&btkr=1"
    visit articles_path

    articles_count = Article.count
    fill_in :article_url, with: url
    click_on :create_article_button

    expect(current_path).to eq articles_path
    expect(page).not_to have_selector "#error_message_area"
    
    target_card = find("#article_cards").all(".article-card")[0]
    expect(target_card.find(".card-header-title")).to have_text url
    expect(target_card.find(".card-image").find("img")[:src]).to include "no_image"
    expect(Article.count).to eq articles_count + 1
  end

  scenario "【記事】の【削除】ボタンを選択した場合、【削除確認ダイアログ】が表示されること" do
    visit articles_path

    page.dismiss_confirm("#{@articles.first.title}を削除しますか？") do
      all(".article-card")[0].find(".card-delete-button").click
    end
  end

  scenario "【削除確認ダイアログ】で【キャンセル】を選択した場合、【記事】は削除されず【削除確認ダイアログ】が閉じること" do
    visit articles_path
    expect(all(".article-card")[0].find(".card-header-title")).to have_text @articles[0].title
    articles_count = Article.count

    page.dismiss_confirm do
      all(".article-card")[0].find(".card-delete-button").click
    end

    expect(current_path).to eq articles_path
    expect(all(".article-card")[0].find(".card-header-title")).to have_text @articles[0].title
    expect(Article.count).to eq articles_count
  end

  scenario "【削除確認ダイアログ】で【OK】を選択した場合、【記事】が削除され【削除確認ダイアログ】が閉じること" do
    visit articles_path
    expect(all(".article-card")[0].find(".card-header-title")).to have_text @articles[0].title
    articles_count = Article.count

    page.accept_confirm do
      all(".article-card")[0].find(".card-delete-button").click
    end

    expect(current_path).to eq articles_path
    expect(all(".article-card")[0].find(".card-header-title")).to have_text @articles[1].title
    expect(Article.count).to eq articles_count - 1
  end

end