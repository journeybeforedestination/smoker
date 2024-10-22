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

ActiveRecord::Schema[8.1].define(version: 2024_10_22_232415) do
  create_table "launch_tokens", force: :cascade do |t|
    t.integer "launch_id", null: false
    t.text "access_token", null: false
    t.datetime "experation", null: false
    t.string "scope", null: false
    t.text "id_token"
    t.text "refresh_token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["launch_id"], name: "index_launch_tokens_on_launch_id"
  end

  create_table "launches", force: :cascade do |t|
    t.string "iss"
    t.string "launch"
    t.string "authorization_endpoint"
    t.string "token_endpoint"
    t.string "state"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "pkce"
  end

  add_foreign_key "launch_tokens", "launches"
end
