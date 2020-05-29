class AddUidColumnToArticles < ActiveRecord::Migration[6.0]
  def change
    add_column :articles, :uid, :string, null: false
    add_index :articles, :uid
  end
end
