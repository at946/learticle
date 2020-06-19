# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_06_17_145836) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.bigint "resource_id"
    t.string "author_type"
    t.bigint "author_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id"
  end

  create_table "articles", force: :cascade do |t|
    t.text "url"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "title"
    t.text "image_url"
    t.string "uid"
    t.datetime "finish_reading_at"
    t.text "memo"
    t.index ["uid"], name: "index_articles_on_uid"
  end

  create_table "user_articles", force: :cascade do |t|
    t.string "user_id", null: false
    t.bigint "article_id", null: false
    t.datetime "finish_reading_at"
    t.text "memo"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["article_id"], name: "index_user_articles_on_article_id"
    t.index ["user_id", "article_id"], name: "index_user_articles_on_user_id_and_article_id", unique: true
    t.index ["user_id"], name: "index_user_articles_on_user_id"
  end

  create_table "users", id: :string, force: :cascade do |t|
    t.string "auth0_uid", null: false
    t.string "name", null: false
    t.text "image", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  add_foreign_key "user_articles", "articles"
  add_foreign_key "user_articles", "users"
end
