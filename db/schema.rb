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

ActiveRecord::Schema.define(:version => 20120103062700) do

  create_table "allergies", :force => true do |t|
    t.string  "name"
    t.integer "parent_id"
    t.string  "display"
  end

  create_table "appliances", :force => true do |t|
    t.string "name"
  end

  create_table "appliances_kitchens", :force => true do |t|
    t.integer "appliance_id"
    t.integer "kitchen_id"
  end

  create_table "balances", :force => true do |t|
    t.integer "veg"
    t.integer "grain"
    t.integer "protein"
    t.text    "description"
  end

  create_table "branches", :force => true do |t|
    t.string  "name"
    t.string  "street"
    t.string  "city"
    t.string  "state"
    t.string  "zip"
    t.string  "phone"
    t.string  "website"
    t.string  "email"
    t.integer "store_id"
  end

  create_table "branches_products", :force => true do |t|
    t.integer "product_id"
    t.integer "branch_id"
    t.integer "on_hand"
    t.string  "location"
  end

  create_table "branches_users", :force => true do |t|
    t.float   "distance"
    t.integer "preference"
    t.integer "user_id"
    t.integer "branch_id"
  end

  create_table "categories", :force => true do |t|
    t.string "name"
  end

  create_table "categories_ingredients", :force => true do |t|
    t.integer "category_id"
    t.integer "ingredient_id"
  end

  create_table "ingredients", :force => true do |t|
    t.string  "name"
    t.integer "recipe_id"
    t.integer "allergen1_id"
    t.integer "allergen2_id"
    t.integer "allergen3_id"
    t.integer "kitchen_id"
    t.boolean "stock_item",   :default => false
    t.text    "other_names",  :default => ""
    t.string  "whole_unit",   :default => ""
  end

  create_table "ingredients_kitchens", :force => true do |t|
    t.integer "kitchen_id"
    t.integer "ingredient_id"
    t.float   "weight"
    t.string  "unit"
    t.text    "note"
    t.boolean "needed"
    t.boolean "bought"
    t.boolean "exclude",       :default => false
    t.boolean "have",          :default => false
  end

  create_table "ingredients_recipes", :force => true do |t|
    t.float   "weight"
    t.string  "unit"
    t.string  "important"
    t.string  "strength"
    t.integer "ingredient_id"
    t.integer "recipe_id"
    t.boolean "group",         :limit => 255, :default => false
    t.string  "description",                  :default => ""
    t.integer "line_num"
  end

  create_table "kitchens", :force => true do |t|
    t.string  "name"
    t.string  "default_meal_days"
    t.integer "default_servings"
  end

  create_table "meal_types", :force => true do |t|
    t.string "name"
  end

  create_table "meals", :force => true do |t|
    t.integer "kitchen_id"
    t.date    "eaten_on"
    t.integer "recipe_id"
    t.float   "servings"
    t.boolean "my_meals",   :default => false
    t.boolean "starred",    :default => false
    t.integer "seen_count", :default => 0
  end

  create_table "personalities", :force => true do |t|
    t.string "name"
    t.binary "picture"
  end

  create_table "points", :force => true do |t|
    t.string  "name"
    t.text    "description"
    t.string  "campaign"
    t.integer "points"
    t.integer "max_times",   :default => 1
  end

  create_table "products", :force => true do |t|
    t.string "name"
  end

  create_table "recipes", :force => true do |t|
    t.string   "name"
    t.text     "cooksteps"
    t.string   "picture_file_name"
    t.string   "picture_content_type"
    t.integer  "picture_file_size"
    t.datetime "picture_updated_at"
    t.text     "original"
    t.text     "source"
    t.string   "tags"
    t.integer  "servings"
    t.integer  "preptime"
    t.integer  "cooktime"
    t.boolean  "approved"
    t.text     "intro"
    t.text     "prepsteps"
    t.string   "skills"
    t.datetime "updated_at"
    t.datetime "balance_updated_at"
    t.integer  "balance_protein"
    t.integer  "balance_vegetable"
    t.integer  "balance_starch"
    t.integer  "kitchen_id"
    t.string   "picture_remote_url"
    t.string   "source_link"
    t.text     "original_ingredient_list"
    t.boolean  "public",                   :default => true
  end

  create_table "recipes_personalities", :force => true do |t|
    t.integer "level"
    t.integer "recipe_id"
    t.integer "personality_id"
  end

  create_table "scategories", :force => true do |t|
    t.string "name"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :default => "", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "skills", :force => true do |t|
    t.string  "name"
    t.text    "description"
    t.string  "video_link"
    t.integer "level"
    t.integer "scategory_id"
  end

  create_table "sliding_scales", :force => true do |t|
    t.string "name1"
    t.string "name2"
  end

  create_table "sort_orders", :force => true do |t|
    t.integer "kitchen_id"
    t.string  "tag"
    t.text    "order"
  end

  create_table "stores", :force => true do |t|
    t.string "name"
    t.string "street"
    t.string "city"
    t.string "state"
    t.string "zip"
    t.string "phone"
    t.string "website"
    t.string "email"
  end

  create_table "users", :force => true do |t|
    t.string   "first"
    t.string   "last"
    t.string   "email"
    t.string   "street"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.integer  "kitchen_id"
    t.string   "crypted_password",   :limit => 128, :default => "", :null => false
    t.integer  "login_count",                       :default => 0
    t.datetime "current_login_at"
    t.datetime "last_login_at"
    t.string   "current_login_ip"
    t.string   "last_login_ip"
    t.string   "password_salt"
    t.integer  "failed_login_count",                :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "role"
    t.string   "persistence_token"
    t.datetime "last_request_at"
    t.integer  "balance_id"
    t.string   "perishable_token",                  :default => ""
  end

  add_index "users", ["email"], :name => "index_members_on_email", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email"
  add_index "users", ["last_request_at"], :name => "index_users_on_last_request_at"
  add_index "users", ["persistence_token"], :name => "index_users_on_persistence_token"

  create_table "users_allergies", :force => true do |t|
    t.integer "level"
    t.integer "user_id"
    t.integer "allergy_id"
  end

  create_table "users_categories", :force => true do |t|
    t.integer "level"
    t.integer "user_id"
    t.integer "category_id"
  end

  create_table "users_ingredients", :force => true do |t|
    t.integer "user_id"
    t.integer "ingredient_id"
    t.boolean "like"
    t.boolean "avoid",         :default => false
  end

  create_table "users_personalities", :force => true do |t|
    t.integer "level"
    t.integer "user_id"
    t.integer "personality_id"
  end

  create_table "users_points", :force => true do |t|
    t.integer  "user_id"
    t.integer  "point_id"
    t.datetime "date_added"
  end

  create_table "users_recipes", :force => true do |t|
    t.integer  "user_id"
    t.integer  "recipe_id"
    t.string   "source"
    t.integer  "rating"
    t.datetime "date_added"
    t.boolean  "active",        :default => false
    t.boolean  "in_recipe_box"
  end

  create_table "users_sliding_scales", :force => true do |t|
    t.integer "level"
    t.integer "user_id"
    t.integer "sliding_scale_id"
  end

end
