class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users, id: :string do |t|
      t.string :auth0_uid,  null: false, unique: true
      t.string :name,       null: false
      t.text :image,        null: false

      t.timestamps
    end
  end
end
