require 'test_helper'
require 'ruby_ext'

class RecipeTest < ActiveSupport::TestCase

  ##########################################
  ## Tests /app/models/recipe.rb 
  ## Tests all methods defined 
  
  test "recipe" do
    r = Recipe.find_by_name("Butternut Squash soup")
    assert_equal 9,r.ingredients.count
  end  
  
  ##########################################
  ## Tests /lib/unit_class_ext.rb, 
  ## Tests all methods defined 
  
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
  	assert_equal "oz", c.get_unit
  	d = Unit.new("1 kg") >> "g"
  	assert_equal 4.545, d.convert_g_to_cup("brown sugar").round(3)  	
  end
  
 	##########################################
  ## Tests /lib/file_ext.rb, 
  ## Tests the methods:
  ##	open_file
  ##	find_pic 
  test "files" do
  
 		assert_equal "watermelon_salsa.JPG", find_pic("test/fixtures/test_recipes/watermelon_salsa.txt")  

  	assert_equal ["Quinoa Salad with Arugula, Apple and Mint", "1 cup quinoa", "4 cups water", "1/4 teaspoon salt", "1/2 cup organic red apple, sliced", "1/4 cup fresh organic lime juice", "1/4 cup organic olive oil", "2 teaspoons honey", "2 cloves organic garlic, minced", "2 tablespoons toasted sunflower seeds", "1/4 cup chopped fresh organic mint",
	 "1 shallot, minced",
	 "1 pinch salt and black pepper to taste",
	 "4 cups baby arugula leaves, washed and rough chopped",
	 "1 tsp white wine vinegar",
	 "**instructions**",
	 "1. Toast the quinoa in a dry skillet over medium heat until it has a nutty aroma. Remove from heat, rinse and drain in a fine mesh strainer. Bring water to a boil in a saucepan, add salt, and slowly add toasted quinoa. Cook until tender and the outer rings appear on the grains, 15 to 20 minutes. Strain through a fine mesh colander. Place in a large bowl to cool.", "2. In a small bowl, combine apples, lime juice, olive oil, honey, garlic, sunflower seeds, mint, shallot, and arugula. Stir into the cooled quinoa and add salt and freshly ground pepper to taste.   Toss in fresh arugula.", "**serves**",
	 "Serves 4.",
	 "**worktime**",
	 "20 min",
	 "**waittime**",
	 "0 min",
	 "**source**",
	 "RealMealz",
	 "**tags**",
	 "main, dinner, vegetarian"],open_file("test/fixtures/test_recipes/QuinoaSalad.txt")  
  end

 
 	##########################################
  ## Tests /lib/string_ext.rb, 
  ## Tests the methods:
  ##	is_unit?
  ##	remove_brackets	
  ##	find_unit
  ##	make_singular
  ##	make_plural
  ## 	closest_string_in_front
  ##	find_closest_num
  ##	find_num
  
  test "string" do
  	assert_equal true, "oz.".is_unit?
  	assert_equal true, "ml".is_unit?
  	assert_equal false, "1 cup".is_unit?
  	assert_equal " 12 oz ","(12 oz)".remove_brackets
  	assert_equal "OZ.","3/4OZ. ".find_unit
  	assert_equal "handfuls","2handfuls ".find_unit
  	assert_equal "235/334 bean and bird","235/334 beans and birds".make_singular
  	assert_equal "beans and birds","bean and bird".make_plural 
  	assert_equal "3 1/2", "1 1/2 3 1/2 oz can chicken broth".closest_string_in_front('oz',/\d+\s\d+\/\d+/)
  	assert_equal  3.5,"1 1/2 3 1/2 oz can chicken broth".find_closest_num("oz")
  	assert_equal 1.5, "1 1/2 3 1/2 oz can chicken broth".find_num
  end
  
  ##########################################
	## Tests array_ext.rb
	## Tests the methods: 
	##	make_singular
	## 	

  test "array" do
  	 assert_equal [ "bean" , "chive" , "anchovy" , "thing" ], ["beans" , "chives" , "anchovies" , "things" ].make_singular
 	end
 	
 	##########################################
	## Tests the methods: 
	## sort_by_length
	## 	
	test "sort_by_length" do
	  sorted_names = 
	  last_name = 'this is a dummy name that is gotta be longer than any ingredient name'
	  Ingredient.sort_by_length.each do |name|
	    assert last_name.length >= name.length, "'#{last_name} not longer or same length as #{name}"
	    last_name = name
    end
	end  
	
  ##########################################
	## Tests recipes.rb
	## Tests the methods: 
	##	parse_ingredients
	##	add_recipe
	## 	
  test "parsing" do
  
		unparsed_text_in_array = ["1 cup quinoa","4 cups water","1/4 teaspoon salt","1/2 cup organic red apple, sliced","1/4 cup fresh organic lime juice","1/4 cup organic olive oil","2 teaspoons honey","2 cloves organic garlic, minced","2 tablespoons toasted sunflower seeds","1/4 cup chopped fresh organic mint","1 shallot, minced","1 pinch salt and black pepper to taste","4 cups baby arugula leaves, washed and rough chopped", "1 tsp white wine vinegar"]

		finished_array = Array.new([["quinoa", 1139, Unit.new("1 cup")],["water", 1102,  Unit.new("4 cup")],["salt", 1389, Unit.new("0.25 tsp")],["apple", 1192, Unit.new("0.5 cup")],["lime juice", 1224, Unit.new("0.25 cup")],["olive oil", 1340, Unit.new("0.25 cup")],["honey", 1478, Unit.new("2 tsp")],["garlic", 1388, Unit.new("2 clove")],["sunflower seed", 1280, Unit.new("2 tbs")],["mint", 1421, Unit.new("0.25 cup")],["shallot", 1101, Unit.new("1")],["black pepper", 1458, Unit.new("1 tsp")],["arugula", 1098, Unit.new("4 cup")],["white wine vinegar", 1386, Unit.new("1 tsp")]])

		assert_equal finished_array, parse_ingredients(unparsed_text_in_array)

		## setting up for calling add_recipe
		originaltext = "original text"
		title = "Test Recipe"
		instructions = "blahblah"
		servings = "3"
		worktime = "10"
		waittime = "20"
		source = "http:\\blah.blah.com\nBy some dude"
		tags = "breakfast, lunch"
		approved = "no"

		##make the function call for add_recipe
    index = add_recipe(originaltext, title, finished_array, instructions, servings, worktime, waittime, source, tags, approved)
		r = Recipe.find_by_id(index)
		assert_equal originaltext, r.original
		assert_equal title, r.name
		assert_equal instructions, r.instructions
		assert_equal servings, r.serving
		assert_equal worktime, r.worktime
		assert_equal source, r.source
		assert_equal tags, r.tags
		assert_equal approved, r.approved

		assert_equal ["apple", "arugula", "black pepper", "garlic", "honey", "lime juice", "mint", "olive oil", "quinoa", "salt", "shallot", "sunflower seed", "water", "white wine vinegar"],r.ingredients.map {|i| i.name }.sort

		assert_equal [0.25, 0.25, 0.25, 0.25, 0.5, 1.0, 1.0, 1.0, 1.0, 2.0, 2.0, 2.0, 4.0, 4.0], r.ingredients_recipes.map {|ir| ir.weight }.sort

		assert_equal [nil, "clove", "cup", "cup", "cup", "cup", "cup", "cup", "cup", "tbs", "tsp", "tsp", "tsp", "tsp"], r.ingredients_recipes.map {|ir| ir.units }.sort_by { |a| [a ? 1 : 0, a] }
	
	end
end
