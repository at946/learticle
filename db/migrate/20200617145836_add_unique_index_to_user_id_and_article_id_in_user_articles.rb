class AddUniqueIndexToUserIdAndArticleIdInUserArticles < ActiveRecord::Migration[6.0]
  def change
    add_index :user_articles, [:user_id, :article_id], unique: true
  end
end
