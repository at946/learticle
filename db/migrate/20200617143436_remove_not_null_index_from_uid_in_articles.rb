class RemoveNotNullIndexFromUidInArticles < ActiveRecord::Migration[6.0]
  def change
    change_column :articles, :uid, :string, null: true
  end
end
