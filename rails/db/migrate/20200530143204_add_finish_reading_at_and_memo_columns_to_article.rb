class AddFinishReadingAtAndMemoColumnsToArticle < ActiveRecord::Migration[6.0]
  def change
    add_column :articles, :finish_reading_at, :datetime
    add_column :articles, :memo, :text
  end
end
