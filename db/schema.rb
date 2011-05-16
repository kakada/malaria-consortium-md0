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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110516074428) do

  create_table "places", :force => true do |t|
    t.string   "name"
    t.string   "name_kh"
    t.string   "code"
    t.integer  "parent_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type"
  end

  create_table "reports", :force => true do |t|
    t.string   "malaria_type"
    t.string   "sex"
    t.integer  "age"
    t.boolean  "mobile"
    t.string   "type"
    t.integer  "sender_id"
    t.integer  "place_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "village_id"
  end

  add_index "reports", ["place_id"], :name => "fk_reports_places"
  add_index "reports", ["sender_id"], :name => "fk_reports_users"
  add_index "reports", ["village_id"], :name => "fk_reports_village"

  create_table "settings", :force => true do |t|
    t.string   "param"
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "thresholds", :force => true do |t|
    t.string   "place_class"
    t.integer  "place_id"
    t.integer  "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "user_name"
    t.string   "password"
    t.string   "phone_number"
    t.string   "role"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "place_id"
    t.string   "salt"
    t.string   "remember_token"
    t.string   "encrypted_password"
    t.string   "email"
    t.integer  "status",             :default => 1
  end

  add_index "users", ["phone_number"], :name => "index_users_on_phone_number", :unique => true
  add_index "users", ["user_name"], :name => "index_users_on_user_name", :unique => true

end
