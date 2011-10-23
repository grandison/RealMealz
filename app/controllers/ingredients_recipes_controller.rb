class IngredientsRecipesController < ApplicationController
  active_scaffold :ingredients_recipes do |config|
    config.label = "Ingredients"
    config.columns = [:weight, :unit, :ingredient, :important, :strength]
    config.columns[:weight].options[:size] = 10;
    config.columns[:weight].options[:size] = 20;
    config.columns[:strength].options[:size] = 5;
    config.columns[:important].form_ui = :select
    config.columns[:important].options = {:options => User.standard_positive_levels}
    config.columns[:strength].form_ui = :select
    config.columns[:strength].options = {:options => User.standard_positive_levels}
  end
end
