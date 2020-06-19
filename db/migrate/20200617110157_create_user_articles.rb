class CreateUserArticles < ActiveRecord::Migration[6.0]
  def change
    create_table :user_articles do |t|
      t.references :user, null: false, foreign_key: true, index: true, type: :string
      t.references :article, null: false, foreign_key: true, index: true
      t.datetime :finish_reading_at
      t.text :memo

      t.timestamps
    end
  end
end
