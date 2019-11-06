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

ActiveRecord::Schema.define(version: 2019_10_27_050220) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "admins", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admins_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true
  end

  create_table "barcodes", force: :cascade do |t|
    t.string "code"
    t.string "owner_type"
    t.bigint "owner_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["code"], name: "index_barcodes_on_code", unique: true
    t.index ["owner_type", "owner_id"], name: "index_barcodes_on_owner_type_and_owner_id", unique: true
  end

  create_table "devices", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.bigint "issuer_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "issued_at"
    t.index ["issuer_id"], name: "index_devices_on_issuer_id"
  end

  create_table "issuers", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.integer "allowance"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "code"
    t.index ["code"], name: "index_issuers_on_code", unique: true
  end

  add_foreign_key "devices", "issuers"
end
