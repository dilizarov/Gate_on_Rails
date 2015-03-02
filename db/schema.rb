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

ActiveRecord::Schema.define(version: 20150302031223) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "authentication_tokens", force: true do |t|
    t.string  "token",   null: false
    t.integer "user_id", null: false
  end

  add_index "authentication_tokens", ["token"], name: "index_authentication_tokens_on_token", using: :btree
  add_index "authentication_tokens", ["user_id"], name: "index_authentication_tokens_on_user_id", using: :btree

  create_table "comments", force: true do |t|
    t.uuid     "external_id",                 null: false
    t.integer  "user_id",                     null: false
    t.integer  "post_id",                     null: false
    t.text     "body",                        null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "cached_votes_up", default: 0
  end

  add_index "comments", ["cached_votes_up"], name: "index_comments_on_cached_votes_up", using: :btree
  add_index "comments", ["external_id"], name: "index_comments_on_external_id", unique: true, using: :btree
  add_index "comments", ["post_id"], name: "index_comments_on_post_id", using: :btree
  add_index "comments", ["user_id"], name: "index_comments_on_user_id", using: :btree

  create_table "devices", force: true do |t|
    t.text     "platform",   null: false
    t.text     "token",      null: false
    t.integer  "user_id",    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "devices", ["token"], name: "index_devices_on_token", using: :btree

  create_table "gates", force: true do |t|
    t.string   "name",                        null: false
    t.integer  "creator_id",                  null: false
    t.text     "external_id",                 null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "generated",   default: false
  end

  add_index "gates", ["creator_id"], name: "index_gates_on_creator_id", using: :btree
  add_index "gates", ["external_id"], name: "index_gates_on_external_id", unique: true, using: :btree

  create_table "keys", force: true do |t|
    t.string   "encrypted_key",   null: false
    t.integer  "gatekeeper_id",   null: false
    t.text     "encrypted_gates", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "keys", ["encrypted_key"], name: "index_keys_on_encrypted_key", unique: true, using: :btree
  add_index "keys", ["gatekeeper_id"], name: "index_keys_on_gatekeeper_id", using: :btree

  create_table "posts", force: true do |t|
    t.uuid     "external_id",                 null: false
    t.integer  "user_id",                     null: false
    t.integer  "gate_id",                     null: false
    t.text     "body",                        null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "comments_count",  default: 0
    t.integer  "cached_votes_up", default: 0
  end

  add_index "posts", ["cached_votes_up"], name: "index_posts_on_cached_votes_up", using: :btree
  add_index "posts", ["external_id"], name: "index_posts_on_external_id", unique: true, using: :btree
  add_index "posts", ["gate_id"], name: "index_posts_on_gate_id", using: :btree
  add_index "posts", ["user_id"], name: "index_posts_on_user_id", using: :btree

  create_table "user_gates", force: true do |t|
    t.integer  "user_id",                       null: false
    t.integer  "gate_id",                       null: false
    t.integer  "gatekeeper_id"
    t.boolean  "anonymous",     default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_gates", ["gate_id"], name: "index_user_gates_on_gate_id", using: :btree
  add_index "user_gates", ["gatekeeper_id"], name: "index_user_gates_on_gatekeeper_id", using: :btree
  add_index "user_gates", ["user_id", "gate_id"], name: "index_user_gates_on_user_id_and_gate_id", unique: true, using: :btree
  add_index "user_gates", ["user_id"], name: "index_user_gates_on_user_id", using: :btree

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
    t.uuid     "external_id",                         null: false
    t.string   "name",                   default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["external_id"], name: "index_users_on_external_id", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "votes", force: true do |t|
    t.integer  "votable_id"
    t.string   "votable_type"
    t.integer  "voter_id"
    t.string   "voter_type"
    t.boolean  "vote_flag"
    t.string   "vote_scope"
    t.integer  "vote_weight"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "votes", ["votable_id", "votable_type", "vote_scope"], name: "index_votes_on_votable_id_and_votable_type_and_vote_scope", using: :btree
  add_index "votes", ["voter_id", "voter_type", "vote_scope"], name: "index_votes_on_voter_id_and_voter_type_and_vote_scope", using: :btree

end
