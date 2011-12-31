require "config/environment"

ingr_combine = Ingredient.find(ARGV[0])
ingr_main = Ingredient.find(ARGV[1])

print "Combine '#{ingr_combine.name}' into '#{ingr_main.name}'? "

answer = $stdin.gets

if answer.downcase[0..0] != "y"
  puts "exiting"
end

Ingredient.combine_ingredients(ingr_combine, ingr_main)



