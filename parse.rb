# Run with: 
#  rails console
#  >> load "parse.rb"

@i = Ingredient.new
@i.name = 'Brown rice'
@c = Category.new
@c.name = 'Rice'
@i.categories << @c
@i.save
