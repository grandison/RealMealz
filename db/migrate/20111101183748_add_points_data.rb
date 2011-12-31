class AddPointsData < ActiveRecord::Migration
  def self.up
    [
      {"name" => "customize:save_food_balance","max_times" => 1, "id" => 2,"points" => 1,"description" => "Update your target food balance"},
      {"name" => "home:create_user","max_times" => 1,"id" => 3,"points" => 30,"description" => "Signing up"},
      {"name" => "customize:add_like_item","max_times" => 10,"id" => 4,"points" => 1,"description" => "Adding an item you like"},
      {"name" => "discover:update_recipe_box","max_times" => 20,"id" => 5,"points" => 2,"description" => "Adding a recipe to your recipe box"},
      {"name" => "plan:add_recipe_to_meals","max_times" => 10,"id" => 6,"points" => 1,"description" => "Adding a recipe to your recipe box."},
      {"name" => "shop:add_item","max_times" => 10,"id" => 7,"points" => 1,"description" => "Add item to pantry list."},
      {"name" => "shop:update","max_times" => 10,"id" => 8,"points" => 1,"description" => "Checking off an item from the shopping list"},
    ].each do |attributes|
      Point.find_or_create_by_name(attributes)
    end
  end

  def self.down
    Point.delete_all
  end
end
