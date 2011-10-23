To initiate your system with recipes from "recipes/imported_recipes/*.txt" run the following in the rails console (rails c).  
Make sure you have ingredients.txt and allergies.txt in your /parsers folder along with the .rb files
	load "parsers/import_recipes.rb"
	load "parsers/import_ingr.rb"
	load "parsers/import_allergies.rb"
	load "parsers/update_ingr_allergens.rb"
	
To add more recipes:
	1. Modify "parsers/import_recipes.rb", change file location referral at the bottom of the file (near line 141) to new directory with recipes in it
	2. run load "parsers/import_recipes.rb"

To add more ingredients:
	1. Add ingredients into "ingredients.txt", in established format, make sure you specify major allergen category for added ingredients (ie: milk, wheat, egg, dairy, soy, treenut, oat, shellfish, fish, meat)
	2. Run below in rails console
	load "parsers/import_ingr.rb"
	load "parsers/update_ingr_allergens.rb"

To add more allergies:
	1. Add allergies into "allergies.txt", in established format
	2. Run below in rails console
	load "parsers/import_allergies.rb"
	load "parsers/update_ingr_allergens.rb"
