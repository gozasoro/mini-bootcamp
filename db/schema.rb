# frozen_string_literal: true

# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2022_03_04_061551) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "archivements", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "challenge_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["challenge_id"], name: "index_archivements_on_challenge_id"
    t.index ["user_id", "challenge_id"], name: "index_archivements_on_user_id_and_challenge_id", unique: true
    t.index ["user_id"], name: "index_archivements_on_user_id"
  end

  create_table "categories", force: :cascade do |t|
    t.string "name", null: false
    t.string "docker_image", null: false
    t.string "command", null: false
    t.string "extension", null: false
    t.string "editor_mode", null: false
    t.integer "row_order"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_categories_on_name", unique: true
  end

  create_table "challenges", force: :cascade do |t|
    t.string "title", null: false
    t.text "content", null: false
    t.text "model_answer", null: false
    t.integer "row_order"
    t.bigint "category_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["category_id"], name: "index_challenges_on_category_id"
    t.index ["title", "category_id"], name: "index_challenges_on_title_and_category_id", unique: true
  end

  create_table "checks", force: :cascade do |t|
    t.text "stdin"
    t.text "stdout", null: false
    t.bigint "challenge_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["challenge_id"], name: "index_checks_on_challenge_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "provider", null: false
    t.string "uid", null: false
    t.string "name", null: false
    t.string "image_url", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "admin", default: false, null: false
    t.index ["provider", "uid"], name: "index_users_on_provider_and_uid", unique: true
  end

  add_foreign_key "archivements", "challenges"
  add_foreign_key "archivements", "users"
  add_foreign_key "challenges", "categories"
  add_foreign_key "checks", "challenges"
end
