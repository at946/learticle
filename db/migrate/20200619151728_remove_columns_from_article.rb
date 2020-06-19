class RemoveColumnsFromArticle < ActiveRecord::Migration[6.0]
  def change
    remove_column :articles, :uid, :string
    remove_column :articles, :finish_reading_at, :datetime
    remove_column :articles, :memo, :text
  end
end
