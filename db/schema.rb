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

ActiveRecord::Schema.define(:version => 20110809084244) do

  create_table "places", :force => true do |t|
    t.string   "name"
    t.string   "name_kh"
    t.string   "code"
    t.integer  "parent_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type",       :limit => 15
    t.decimal  "lat",                      :precision => 11, :scale => 8
    t.decimal  "lng",                      :precision => 11, :scale => 8
    t.string   "hierarchy"
  end

  add_index "places", ["parent_id", "name"], :name => "index_places_on_parent_id_and_name"
  add_index "places", ["type"], :name => "index_places_on_type"

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
    t.integer  "health_center_id", :default => 0
    t.integer  "od_id",            :default => 0
    t.integer  "province_id",      :default => 0
    t.string   "text"
    t.boolean  "error",            :default => false
    t.string   "error_message"
    t.string   "sender_address"
    t.integer  "country_id"
    t.string   "nuntium_token"
    t.boolean  "ignored",          :default => false
    t.boolean  "trigger_to_od"
  end

  add_index "reports", ["country_id", "error", "ignored"], :name => "index_reports_on_country_id_and_error_and_ignored"
  add_index "reports", ["error", "village_id", "created_at"], :name => "index_reports_on_error_and_village_id_and_created_at"
  add_index "reports", ["health_center_id", "error", "ignored"], :name => "index_reports_on_health_center_id_and_error_and_ignored"
  add_index "reports", ["od_id", "error", "ignored"], :name => "index_reports_on_od_id_and_error_and_ignored"
  add_index "reports", ["place_id", "error"], :name => "index_reports_on_place_id_and_error"
  add_index "reports", ["province_id", "error", "ignored"], :name => "index_reports_on_province_id_and_error_and_ignored"
  add_index "reports", ["sender_id"], :name => "fk_reports_users"
  add_index "reports", ["village_id", "error"], :name => "index_reports_on_village_id_and_error"

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
    t.string   "place_hierarchy"
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
    t.string   "encrypted_password",     :limit => 128, :default => "",   :null => false
    t.string   "email"
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                         :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "place_class",            :limit => 15
    t.integer  "health_center_id"
    t.integer  "od_id"
    t.integer  "province_id"
    t.integer  "country_id"
    t.integer  "village_id"
    t.boolean  "status",                                :default => true
  end

  add_index "users", ["country_id", "place_class"], :name => "index_users_on_country_id_and_place_class"
  add_index "users", ["health_center_id", "place_class"], :name => "index_users_on_health_center_id_and_place_class"
  add_index "users", ["od_id", "place_class"], :name => "index_users_on_od_id_and_place_class"
  add_index "users", ["phone_number"], :name => "index_users_on_phone_number"
  add_index "users", ["place_id"], :name => "index_users_on_place_id"
  add_index "users", ["province_id", "place_class"], :name => "index_users_on_province_id_and_place_class"
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  add_index "users", ["user_name"], :name => "index_users_on_user_name", :unique => true
  add_index "users", ["village_id", "place_class"], :name => "index_users_on_village_id_and_place_class"

end
