require 'test_helper'

class RecipeTest < ActiveSupport::TestCase

  #--------------
  test "conversions" do
  	a = Unit.new("3/4 cup")
  	assert_equal 0.75, a.get_scalar
  	assert_equal "cup", a.get_unit
  	
  	b = Unit.new("2 cloves")
  	assert_equal 2, b.get_scalar
  	assert_equal "clove", b.get_unit
  	assert_equal 0.7705, (a+b).get_scalar.round(4)
  	assert_equal "cup", (a+b).get_unit
  	c = b >> "oz"
		assert_equal 0.164, c.get_scalar.round(3)
  	assert_equal "ounce", c.get_unit
  	
  	d = Unit.new("1 kg") >> "g"
  	assert_equal 4.545, d.convert_to_volume("brown sugar").get_scalar.round(3)  	
  end
  
  #--------------
  test "make singular" do
  	 assert_equal [ "bean" , "chive" , "anchovy" , "thing" ], ["beans" , "chives" , "anchovies" , "things" ].map {|n| n.singularize}
 	end
 	
  #--------------
	test "ingredients sort by length" do
	  ['bean', 'anchovy', 'korean bulgogi marinade', 'soy', 'refrigerated crescent roll', 'broccoli', 'salt', 'ruttabagas'].each do |name| 
	    Ingredient.create(:name => name)
    end
	  last_name = 'this is a dummy name that is gotta be longer than any ingredient name'
	  Ingredient.create_hash_by_name_length.each do |ingr_hash|
	    name = ingr_hash[:name]
	    assert last_name.length >= name.length, "'#{last_name} not longer or same length as #{name}"
	    last_name = name
    end
	end  
	
  #--------------
  test "process ingredients" do
    test_ingredients = <<-EOF
      1 cup quinoa
      4.5 cups water
      1/4 teaspoon salt
      2 organic red apples, sliced
		  1/4 cup fresh organic lime juice
		  2 teaspoons unknown_ingredient
		  2 cloves organic garlic, minced
		  1/4 cup chopped fresh organic mint, (2 bunches)
		  1 shallot, minced
		  1 pinch salt, and black pepper to taste
		  4 1/2 cups baby arugula leaves, washed and rough chopped
     EOF
    ['quinoa', 'water', 'salt', 'soy', 'apple|apples', 'lime|limes', 'lime juice', 'garlic',
      'mint', 'shallot|shallots', 'pepper', 'arugula'].each do |names| 
	    Ingredient.create(:name => names.split("|")[0].capitalize, :other_names => names)
    end
    Ingredient.find_by_name('Garlic').update_attributes!(:whole_unit => 'clove')
    Ingredient.find_by_name('Salt').update_attributes!(:whole_unit => 'pinch')
    Ingredient.reset_cache
    
    recipe = Recipe.new
    recipe.ingredient_list = test_ingredients
    recipe.process_ingredient_list
    
    assert_equal test_ingredients, recipe.original_ingredient_list
    assert_equal '1 cup Quinoa', recipe.ingredients_recipes[0].name
    assert_equal '4.5 cups Water', recipe.ingredients_recipes[1].name
    assert_equal '1/4 tsp Salt', recipe.ingredients_recipes[2].name
    assert_equal '2 Apples', recipe.ingredients_recipes[3].name
    assert_equal 'organic red, sliced', recipe.ingredients_recipes[3].description
    assert_equal '1/4 cup Lime juice', recipe.ingredients_recipes[4].name
    assert_equal 'fresh organic', recipe.ingredients_recipes[4].description
    assert_equal '2 tsps (unknown)', recipe.ingredients_recipes[5].name
    assert_equal '2 cloves Garlic', recipe.ingredients_recipes[6].name
    assert_equal 'organic, minced', recipe.ingredients_recipes[6].description
    assert_equal '1/4 cup Mint', recipe.ingredients_recipes[7].name
    assert_equal '1 Shallot', recipe.ingredients_recipes[8].name
    assert_equal 'minced', recipe.ingredients_recipes[8].description
    assert_equal '1 pinch Salt', recipe.ingredients_recipes[9].name
    assert_equal '4.5 cups Arugula', recipe.ingredients_recipes[10].name
    assert_equal 'baby leaves, washed and rough chopped', recipe.ingredients_recipes[10].description
  end

  #--------------
  test "process group with same name as ingredient" do
    test_ingredients = <<-EOF
      2 cups black-eyed peas
      2 english muffins
      Sriracha sauce (opt.)
      
      *Hollandaise Sauce*
      1 large egg yolk
      1 cup butter, melted preferably clarified
     EOF
    ['black-eyed peas', 'english muffins', 'sriracha sauce', 'hollandaise sauce', 'egg yolk', 'butter'].each do |names| 
      Ingredient.create(:name => names.split("|")[0].capitalize, :other_names => names)
    end
    Ingredient.reset_cache
    
    recipe = Recipe.new
    recipe.ingredient_list = test_ingredients
    recipe.process_ingredient_list

    assert_equal 'Hollandaise Sauce', recipe.ingredients_recipes[3].description
    assert recipe.ingredients_recipes[3].group?, "Group"
    
    #Reprocess again
    recipe.process_ingredient_list
    recipe.ingredient_list = nil # force recipe to regenerate list
    assert_equal 'Hollandaise Sauce', recipe.ingredients_recipes[3].description
    assert recipe.ingredients_recipes[3].group?, "Group"
  end

	#--------------
	test "ingredient_list" do
	  recipe = Recipe.create
    recipe.ingredients_recipes << IngredientsRecipe.create(:weight => 1, :unit => 'lb', 
      :ingredient => Ingredient.create(:name => 'Beef'))
    recipe.ingredients_recipes << IngredientsRecipe.create(:weight => 2, :unit => 'tbs', 
      :ingredient => Ingredient.create(:name => 'Salt'))
    assert_equal "1 lb Beef\n2 tbs Salt\n", recipe.ingredient_list
  end
	
	#--------------
	test "process recipe" do
	  ['rice', 'celery', 'chicken'].each do |name| 
	    Ingredient.create(:name => name)
    end
    Ingredient.reset_cache
	  
	  recipe = Recipe.new({"name"=>"Max's Recipe", "cooksteps"=>"2. Cook", "picture_remote_url"=>"", "intro"=>"Love this recipe", 
	    "ingredient_list"=>"3 cup rice\r\n1 stalk celery\r\n1/2 lbs chicken", "skills"=>"Bake", "tags"=>"Main", "preptime"=>"10", 
	    "servings"=>"4", "prepsteps"=>"1. Put together", "source"=>"Max source", "cooktime"=>"10"})
    recipe.process_recipe
        
    assert_equal "Max's Recipe", recipe.name
    assert_equal "Bake", recipe.skills
        
    ir = recipe.ingredients_recipes.first
    assert_equal 'rice', ir.ingredient.name
    assert_equal 3.0, ir.weight.round(2)
    assert_equal 'cup', ir.unit
    assert_equal "3 cups rice", ir.name

    ir = recipe.ingredients_recipes.last
    assert_equal 'chicken', ir.ingredient.name
    assert_equal 0.5, ir.weight
    assert_equal 'lbs', ir.unit
    assert_equal "1/2 lbs chicken", ir.name
    
    assert_equal '3 cups rice', recipe.ingredients_recipes[0].name
  end

	#--------------
	test "parse html" do
	  Ingredient.delete_all
    ['Olive oil', 'Salt', 'Pepper', 'Butter', 'Mushroom', 'Shallot', 'Tomato',
      'Onion', 'Carrot', 'Celery', 'Chicken', 'White wine'].each do |name| 
	    Ingredient.create(:name => name)
    end
    Ingredient.reset_cache
	  
	  url = 'test/fixtures/foodnetwork.com_recipe.html'
	  recipe = Recipe.create_from_html(url)

    # Main list of ingredients
	  assert_equal 'Pan-Roasted Chicken Breasts with a Chasseur Sauce', recipe.name
	  assert_equal '2 tbs Olive oil', recipe.ingredients_recipes[0].name
	  assert_equal '1/3 cup White wine, dry', recipe.ingredients_recipes[7].name_and_description
	  
	  # First group of ingredients
	  assert_equal 'For the Brown Chicken Stock:', recipe.ingredients_recipes[12].description
	  assert recipe.ingredients_recipes[12].group?, "First group"
	  assert_equal '*For the Brown Chicken Stock:*', recipe.ingredients_recipes[12].name
	  
	  # Last group
	  assert_equal '*Pommes Anna:*', recipe.ingredients_recipes[31].name
	  assert_equal '1/4 cup Butter', recipe.ingredients_recipes[33].name

    # Other recipe info
	  assert_equal 15, recipe.preptime, 'preptime'
	  assert_equal 25, recipe.cooktime, 'cooktime'
	  assert_equal 4, recipe.servings, 'servings'
	  assert_equal '(The success of', recipe.intro[0..14], 'intro'
	  assert_equal '2 cups dark chicken stock', recipe.cooksteps[0,25], 'cooksteps'
	  assert_equal 'Glazed Carrots.', recipe.cooksteps[-17,15], 'cooksteps'
	  assert_equal 'Food Network', recipe.source, 'source'
	  assert_equal url, recipe.source_link, 'source_link'
	  assert_equal 'http://img.foodnetwork.com/FOOD/2007/07/12/EE0909_Chasseur_Chicken_lg.jpg', recipe.picture_remote_url, 'picture remote url'
  end
  
  #--------------
  test "food balance" do
    recipe = Recipe.create
    recipe.ingredients_recipes << IngredientsRecipe.create(:weight => 1, :unit => 'cup', 
      :ingredient => Ingredient.create(:name => 'Beef'))
    recipe.ingredients_recipes << IngredientsRecipe.create(:weight => 2, :unit => 'cup', 
      :ingredient => Ingredient.create(:name => 'Potato'))
    recipe.ingredients_recipes << IngredientsRecipe.create(:weight => 3, :unit => 'cup', 
      :ingredient => Ingredient.create(:name => 'Vegetable'))
    recipe.ingredients[0].categories << Category.create(:name => 'protein')
    recipe.ingredients[1].categories << Category.create(:name => 'starch')
    recipe.ingredients[2].categories << Category.create(:name => 'vegetable')
    
    balance = recipe.food_balance
    assert_equal({:protein => 1, :starch => 2, :vegetable => 3}, balance)
  end

end
