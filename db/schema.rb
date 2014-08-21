# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140821153140) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "comments", force: true do |t|
    t.uuid     "external_id", null: false
    t.integer  "user_id",     null: false
    t.integer  "status_id",   null: false
    t.text     "body",        null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["external_id"], name: "index_comments_on_external_id", unique: true, using: :btree
  add_index "comments", ["status_id"], name: "index_comments_on_status_id", using: :btree
  add_index "comments", ["user_id"], name: "index_comments_on_user_id", using: :btree

  create_table "keys", force: true do |t|
    t.string   "encrypted_key",      null: false
    t.integer  "gatekeeper_id",      null: false
    t.text     "encrypted_networks", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "keys", ["encrypted_key"], name: "index_keys_on_encrypted_key", unique: true, using: :btree
  add_index "keys", ["gatekeeper_id"], name: "index_keys_on_gatekeeper_id", using: :btree

  create_table "networks", force: true do |t|
    t.string   "name",        null: false
    t.integer  "creator_id",  null: false
    t.uuid     "external_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "networks", ["creator_id"], name: "index_networks_on_creator_id", using: :btree
  add_index "networks", ["external_id"], name: "index_networks_on_external_id", unique: true, using: :btree

  create_table "statuses", force: true do |t|
    t.uuid     "external_id", null: false
    t.integer  "user_id",     null: false
    t.integer  "network_id",  null: false
    t.text     "body",        null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "statuses", ["external_id"], name: "index_statuses_on_external_id", unique: true, using: :btree
  add_index "statuses", ["network_id"], name: "index_statuses_on_network_id", using: :btree
  add_index "statuses", ["user_id"], name: "index_statuses_on_user_id", using: :btree

  create_table "user_networks", force: true do |t|
    t.integer  "user_id",                       null: false
    t.integer  "network_id",                    null: false
    t.integer  "gatekeeper_id"
    t.boolean  "anonymous",     default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_networks", ["gatekeeper_id"], name: "index_user_networks_on_gatekeeper_id", using: :btree
  add_index "user_networks", ["network_id"], name: "index_user_networks_on_network_id", using: :btree
  add_index "user_networks", ["user_id"], name: "index_user_networks_on_user_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "authentication_token"
    t.uuid     "external_id",                         null: false
    t.string   "name",                   default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["authentication_token"], name: "index_users_on_authentication_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["external_id"], name: "index_users_on_external_id", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
