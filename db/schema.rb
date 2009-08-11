# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.


ActiveRecord::Schema.define(:version => 20090805202017) do

  create_table "bookmarks", :force => true do |t|
    t.string   "title",                   :limit => 50, :default => ""
    t.datetime "created_at",                                            :null => false
    t.string   "bookmarkable_type",       :limit => 15, :default => "", :null => false
    t.integer  "bookmarkable_id",                       :default => 0,  :null => false
    t.integer  "user_id",                               :default => 0,  :null => false
    t.datetime "reminder_1_delivered_at"
    t.datetime "reminder_2_delivered_at"
  end

  add_index "bookmarks", ["user_id"], :name => "fk_bookmarks_user"

  create_table "comments", :force => true do |t|
    t.string   "title",            :limit => 50, :default => ""
    t.text     "comment"
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  add_index "comments", ["commentable_id"], :name => "index_comments_on_commentable_id"
  add_index "comments", ["commentable_type"], :name => "index_comments_on_commentable_type"
  add_index "comments", ["user_id"], :name => "index_comments_on_user_id"

  create_table "event_translations", :force => true do |t|
    t.string   "locale",      :limit => 2
    t.integer  "event_id"
    t.text     "title"
    t.text     "description"
    t.string   "location"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "events", :force => true do |t|
    t.integer  "organisation_id",                     :null => false
    t.text     "title"
    t.text     "description"
    t.datetime "startdate"
    t.datetime "enddate"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "address"
    t.string   "city"
    t.string   "location"
    t.string   "link"
    t.float    "latitude"
    t.float    "longitude"
    t.datetime "new_delivered_at"
    t.datetime "updated_delivered_at"
    t.datetime "deleted_at"
    t.integer  "user_id",                                 :null => false
    t.integer  "event_type_id",        :default => 0
    t.boolean  "canceled",             :default => false
  end

  create_table "organisations", :force => true do |t|
    t.text     "title"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "link"
  end

  create_table "organizers", :force => true do |t|
    t.integer  "user_id",         :null => false
    t.integer  "organisation_id", :null => false
    t.integer  "role",            :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "page_views", :force => true do |t|
    t.string  "url"
    t.integer "count"
    t.date    "date"
  end

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type"], :name => "index_taggings_on_taggable_id_and_taggable_type"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "email"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.string   "activation_code",           :limit => 40
    t.datetime "activated_at"
    t.string   "state",                                   :default => "passive"
    t.datetime "deleted_at"
    t.integer  "role",                                    :default => 0
    t.integer  "zip_id"
  end

  create_table "zips", :force => true do |t|
    t.string "zip",       :limit => 5
    t.string "name"
    t.float  "latitude"
    t.float  "longitude"
  end

  add_index "zips", ["zip"], :name => "index_zips_on_zip", :unique => true

end
